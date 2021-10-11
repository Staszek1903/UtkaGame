tool
extends Spatial

export(float,0.0, 1.0) var value setget set_value, get_value
onready var needle = $Needle

func set_value(v:float):
	v = clamp(v,0.0,1.0)
	#print(v)
	value = v
	v *= -180.0
	needle.rotation_degrees.y = v
	#print("value update: ", needle.rotation_degrees)

func get_value()-> float:
	return value
	
