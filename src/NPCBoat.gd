extends BasicBoat

onready var pidc = $PidController
onready var engine = $Engine
onready var rudder = $Rudder
onready var wind_man = $"/root/WindManager"
onready var path:Path = $"../../Path"
onready var path_points = path.curve.get_baked_points() if path else null
onready var jib = $"../fok_sheet"


var nav_id = 0
onready var nav_point = path_points[nav_id] if path_points else null

export(float) var target_angle = 0 setget set_target_angle
export(NodePath) var next_gate

func _ready():
	assert(wind_man)
	assert(next_gate)
	next_gate = get_node(next_gate)
	next_gate.connect("passed_through",self, "_on_gate_passed_through")
#	path_points = []
#	for i in path.curve.get_point_count():
#		path_points.append(path.curve.get_point_position(i))
	#print("count: ", path.curve.get_point_count())
	#print("PATHLEN: ", path_points.size())
	assert(jib)
	
	bom.is_sail_up = false
	jib.is_sail_up = false
	engine.is_on = false
	
#	yield(get_tree().create_timer(2), "timeout")
#
#	engine.toggle_engine()
#	engine.set_gear("F")
#	engine.set_thrust(0.5)
	set_sail_trim(15)
	
func activate():
	bom.is_sail_up = true
	jib.is_sail_up = true
	
func deactivate():
	bom.is_sail_up = false
	jib.is_sail_up = false

func set_target_angle(val:float):
	print("target_setter1 ",val)
	#while(val>PI): val -= 2*PI
	#while(val<-PI): val += 2*PI
	val = wrapf(val, -PI, PI)
	print("target_setter2 ",val)
	target_angle = val


func update_rudder():
	if linear_velocity.length() < 0.001 :return

	var g_rot_y: float = global_transform.basis.get_euler().y
	var error = g_rot_y - target_angle
	error = wrapf(error, -PI, PI)
	#print("E: ", error)
	
	var l_v = linear_velocity
	l_v.y = 0.0
	var vel =  l_v.length_squared()/2.0
	
	var response = pidc.integrate(error)
	rudder.set_angle_normalized(response*vel)


func _on_gate_passed_through():
	next_gate.disconnect("passed_through",self, "_on_gate_passed_through")
	next_gate = next_gate.next_gate_node
	if next_gate:
		next_gate.connect("passed_through",self, "_on_gate_passed_through")

func update_target_angle():
#	if not path: return
#	var nav_vector = (nav_point-global_transform.origin)
#
#	if nav_vector.length_squared() < 25:
#		nav_id = wrapi(nav_id+1,0,path_points.size())
#		nav_point = path_points[nav_id]
	if not next_gate: return
	var nav_vector = next_gate.global_transform.origin - global_transform.origin
	

	var nav_point_angle = atan2(-nav_vector.x, -nav_vector.z)
	var wind_tack = sign(wind_man.global_wind_vector.dot(global_transform.basis.x))
	#var vel_heading:float = get_velocity_heading()
	var wind_angle = wind_man.get_apparent_wind_angle(linear_velocity)
	var oposite_wind_angle = wrapf(wind_angle+PI,0,2*PI)
	#var drift_angle = angle_diff(global_transform.basis.get_euler().y,vel_heading)
	
	var wind_nav_angle = angle_diff(wrapf(wind_man.wind_angle+PI,-PI,PI), nav_point_angle)
	#var wind_vel_angle = angle_diff(wrapf(wind_man.wind_angle+PI,-PI,PI), vel_heading)

	
	target_angle = wrapf(nav_point_angle, 0, 2*PI)
	if wind_nav_angle < deg2rad(60.0):			#MAGIC NUMBER !!!!! :<<<
		target_angle = wrapf(oposite_wind_angle - wind_tack*deg2rad(25.0), 0, 2*PI)
	elif wind_nav_angle > deg2rad(170):
		target_angle = wrapf(oposite_wind_angle - wind_tack*deg2rad(170), 0, 2*PI)
	#print(target_angle)

func update_sail_trim():
	var new_sail_trim = sail_trim
	var wind_tack = sign(wind_man.global_wind_vector.dot(global_transform.basis.x))
	var bom_tack = sign(bom.global_transform.basis.z.dot(-global_transform.basis.x))
	var wind_angle = 180.0 - rad2deg(bom.wind_angle)# 0 ... 180 -> 10
	#print("S A: ", wind_angle," ",sail_trim, " T: ", wind_tack, " ", bom_tack)

	if wind_tack != bom_tack: 
		new_sail_trim -= 0.1
	elif bom.global_force.dot(-global_transform.basis.z) < 0.0:
		new_sail_trim -= 0.1
	elif wind_angle < 10.0 :
		new_sail_trim -= 0.1
	elif wind_angle > 20.0 :
		new_sail_trim += 0.1

	set_sail_trim(clamp(new_sail_trim, 15.0 if linear_velocity.length()>0.5 else 0.0, 90.0))


func get_velocity_heading():
	var vel_direction:Vector3 = linear_velocity
	vel_direction.y = 0
	vel_direction = vel_direction.normalized()
	var vel_basis:Basis = Basis(Vector3.UP.cross(-vel_direction), Vector3.UP, -vel_direction)
	vel_basis = vel_basis.orthonormalized()
	return vel_basis.get_euler().y
	
func angle_diff(a:float, b:float) -> float:
	var diff = abs(a-b)
	if diff > PI :
		diff = 2*PI - diff
	return diff


func _physics_process(_delta):
	update_rudder()
	update_target_angle()
	update_sail_trim()
	
func set_sail_trim(val: float):
	val = clamp(val, 0.0, 90.0)
	sail_trim = val
	hinge_bom.set("angular_limit/upper", val)
	hinge_bom.set("angular_limit/lower", -val)
	hinge_jib.set("angular_limit/upper", val)
	hinge_jib.set("angular_limit/lower", -val)
