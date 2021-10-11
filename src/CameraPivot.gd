extends Position3D

# Called when the node enters the scene tree for the first time.
var angle = 0
var pitch = 0

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
	
#	var rot = get_parent().global_transform.basis.inverse()
#	transform = rot
	
	global_transform.basis = Basis()
	global_rotate(Vector3.RIGHT, pitch)
	global_rotate(Vector3.UP, angle)
	
	
	var speed = Input.get_last_mouse_speed()
	#angle += speed.x/10000
	#if Input.is_action_pressed("ui_right"): angle += 0.1
	#if Input.is_action_pressed("ui_left"): angle -= 0.1

var pressed = false
func _input(event):
	if pressed and event is InputEventMouseMotion:
		angle += event.speed.x /10000
		pitch += event.speed.y /10000		
	
	if event is InputEventMouseButton :
		pressed = event.is_pressed()
