extends RigidBody


onready var force_offset = $ForceOffset
onready var debug = $ForceDebug
onready var wind_manager = $"/root/Root/WindManager"
#onready var mainsailanim:AnimationPlayer = $"../MainSailPlayer"
#onready var foksailanim:AnimationPlayer = $"../FokAnimPlayer"

export(float) var lift_force = 20.0	
export(float) var direct_force = 40.0
export(float) var dead_angle_degree = 15 setget set_dead_angle_degree
export(float) var dead_angle_rad = deg2rad(15) setget set_dead_angle_rad

var is_sail_up = true

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(wind_manager)

func set_dead_angle_degree(val: float):
	dead_angle_degree = val
	dead_angle_rad = deg2rad(val)

func set_dead_angle_rad(val: float):
	dead_angle_rad = val
	dead_angle_degree = rad2deg(val)
	
	
func dead_angle_quotient(angle: float) ->float:
	var a = -1/dead_angle_rad
	var q = a* angle -a * PI
	return clamp(q, 0,1)

func _physics_process(delta):
	#print("dead angle: ", dead_angle)
	var global_force_normal : Vector3 = \
		global_transform.basis.xform(Vector3.RIGHT).normalized()
	var global_heading_normal : Vector3 = \
		-global_transform.basis.xform(Vector3.FORWARD).normalized()
	var global_offset = force_offset.to_global(Vector3()) - to_global(Vector3())
	var global_wind : Vector3 = wind_manager.global_wind_vector \
		* wind_manager.wind_speed
	global_wind -= linear_velocity # real wind to relative wind

	var wind_angle: float = \
	global_heading_normal.angle_to(global_wind)
	#global_wind.angle_to(global_heading_hormal)
	var c = cos(wind_angle)
	var s = sin(wind_angle)
	var dead_zone = dead_angle_quotient(wind_angle)
	var side = sign(global_heading_normal.cross(global_wind).y)
	
	var direct: float = s * direct_force
	var lift: float  = dead_zone* -clamp(c,-1,0) * lift_force
	var global_force: Vector3 =  side * (lift + direct) * global_force_normal
	#print("angle: ", rad2deg(wind_angle))
	#print("dead: ", dead_zone)

	if is_sail_up: add_force(global_force * delta, global_offset) 

	#var sail_fill = (lift + direct) / (lift_force + direct_force)
	#mainsail.scale.x = -side* sail_fill * 2

	debug.clear()
	debug.draw(global_force * 0.1, Color.aqua)
	debug.draw(global_heading_normal, Color.green)
	debug.draw(global_wind, Color.red)
