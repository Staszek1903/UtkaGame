extends Node

var initial_angle:float = PI
var wind_angle:float = initial_angle
var prev_wind_angle:float = initial_angle
var next_wind_angle:float = initial_angle
var interpolation_weight:float = 0.0

var wind_change_time:float = 120.0

var global_wind_vector: Vector3 = Vector3(-sin(wind_angle),0,-cos(wind_angle))

export(float) var wind_speed: float = 2.0

func _ready():
	pass
	#change_target_wind()

func _process(delta):
	if interpolation_weight > 1.0 : return
	interpolation_weight += delta / wind_change_time
	wind_angle = lerp_angle(prev_wind_angle,
							next_wind_angle,
							interpolation_weight)
	global_wind_vector = Vector3(-sin(wind_angle),0,-cos(wind_angle))
	#ProjectSettings.set("physics/3d/default_gravity_vector", global_wind_vector)
	#print(ProjectSettings.get("physics/3d/default_gravity_vector"))
	
func change_target_wind():
	prev_wind_angle = next_wind_angle
	next_wind_angle = randf() * PI * 2
	interpolation_weight = 0.0
	print("cur_wind: ", wind_angle, " next wind: ", next_wind_angle)
	
	yield(get_tree().create_timer(wind_change_time), "timeout")
	change_target_wind()
	
func get_apparent_wind_angle(boat_velocity:Vector3) -> float:
	var wind = (global_wind_vector * wind_speed - boat_velocity).normalized()
	var basis = Basis(-wind.cross(Vector3.UP), Vector3.UP, -wind)
	return basis.get_euler().y
