extends Path

signal path_finished

export(bool) var is_looped:bool = false

onready var control = get_parent()
onready var boat = control.boat

var current_ind:int setget set_current_ind
var target_position:Vector2

func _ready():
	call_deferred("get_boat")
	set_current_ind(0)

func get_boat():
	boat = control.boat

func _process(delta):
	var global_pos = boat.global_transform.origin
	var boat_pos = Vector2(global_pos.x, global_pos.z)
	var nav_vector = ( target_position - boat_pos )

	if nav_vector.length_squared() < 25:
		self.current_ind += 1

	var target_angle = atan2(-nav_vector.x, -nav_vector.y)

	var wind_tack = sign(control.wind_man.global_wind_vector.dot(
		boat.global_transform.basis.x))

	var vel_heading:float = boat.get_velocity_heading()
	var wind_angle = control.wind_man.get_apparent_wind_angle(
		boat.linear_velocity)
	var oposite_wind_angle = wrapf(wind_angle+PI,0,2*PI)
	var drift_angle = control.angle_diff(global_transform.basis.get_euler().y,vel_heading)
	
	var wind_nav_angle = control.angle_diff(wrapf(control.wind_man.wind_angle+PI,-PI,PI), target_angle)
	var wind_vel_angle = control.angle_diff(wrapf(control.wind_man.wind_angle+PI,-PI,PI), vel_heading)

	
	target_angle = wrapf(target_angle, 0, 2*PI)
	if wind_nav_angle < deg2rad(60.0):			#MAGIC NUMBER !!!!! :<<<
		target_angle = wrapf(oposite_wind_angle - wind_tack*deg2rad(25.0), 0, 2*PI)
	elif wind_nav_angle > deg2rad(170):
		target_angle = wrapf(oposite_wind_angle - wind_tack*deg2rad(170), 0, 2*PI)
	
	control.target_angle = target_angle
	#print(target_angle)

func set_current_ind(val:int):
	var point_count = curve.get_point_count()
	
	current_ind = val
	
	if is_looped:
		current_ind = wrapi(val, 0, point_count-1)
	
	if not is_looped and val >= point_count:
		emit_signal("path_finished")
		current_ind = point_count - 1
		
	var local_position = curve.get_point_position(current_ind)
	var global_position = to_global(local_position)
	target_position = Vector2(global_position.x,
		global_position.z)
