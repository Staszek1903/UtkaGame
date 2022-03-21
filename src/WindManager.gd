extends Node

var wind_angle:float = 0.0
var prev_wind_angle:float = 0.0
var next_wind_angle:float = PI*0.5
var interpolation_weight:float = 0.0

var wind_change_time:float = 200.0

var global_wind_vector: Vector3 = Vector3(cos(wind_angle),0,sin(wind_angle))

export(float) var wind_speed: float = 2.0

func _ready():
	#pass
	change_target_wind()

func _process(delta):
	if interpolation_weight > 1.0 : return
	interpolation_weight += delta / wind_change_time
	wind_angle = lerp_angle(prev_wind_angle,
							next_wind_angle,
							interpolation_weight)
	global_wind_vector = Vector3(cos(wind_angle),0,sin(wind_angle))
	#ProjectSettings.set("physics/3d/default_gravity_vector", global_wind_vector)
	#print(ProjectSettings.get("physics/3d/default_gravity_vector"))
	
func change_target_wind():
	yield(get_tree().create_timer(wind_change_time), "timeout")
	prev_wind_angle = next_wind_angle
	next_wind_angle = randf() * PI * 2
	interpolation_weight = 0.0
	print("cur_wind: ", wind_angle, " next wind: ", next_wind_angle)
	change_target_wind()
	
	
