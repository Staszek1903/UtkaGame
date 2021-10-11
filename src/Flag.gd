extends Position3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
#	var basis = global_transform.basis
#	var rot = basis.get_euler()
#
#	rotation.y = -rot.y 
	global_transform.basis = Basis().rotated(Vector3.UP, PI/2)
