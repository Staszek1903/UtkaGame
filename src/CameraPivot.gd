extends Position3D

signal rotated

export(float) var zoom_min = 4
export(float) var zoom_max = 12
export(float) var height_max

export(float) var zoom_speed = 0.5

onready var camera = $Camera

var angle = 0
var pitch = 0

func _ready():
	pass # Replace with function body.

func _process(_delta):
	pass
	
#	var rot = get_parent().global_transform.basis.inverse()
#	transform = rot
	
	global_transform.basis = Basis()
	global_rotate(Vector3.RIGHT, pitch)
	global_rotate(Vector3.UP, angle)
	
	
	#var speed = Input.get_last_mouse_speed()
	#angle += speed.x/10000
	#if Input.is_action_pressed("ui_right"): angle += 0.1
	#if Input.is_action_pressed("ui_left"): angle -= 0.1

var pressed = false
func _input(event):
	if pressed and event is InputEventMouseMotion:
		angle += event.speed.x /10000
		pitch += event.speed.y /10000
		emit_signal("rotated", angle, pitch)
	
	if event is InputEventMouseButton:
		#print("button: ", event.button_index)
		match event.button_index:
			BUTTON_RIGHT:
				pressed = event.is_pressed()
			BUTTON_WHEEL_UP:
				camera.translate(Vector3.FORWARD * zoom_speed)
				camera.translation.z = clamp(camera.translation.z,
					zoom_min,zoom_max) 
				print($Camera.translation)
			BUTTON_WHEEL_DOWN:
				camera.translate(Vector3.BACK * zoom_speed)
				camera.translation.z = clamp(camera.translation.z,
					zoom_min,zoom_max) 
				print($Camera.translation) 

func get_boat()->RigidBody:
	var parent = get_parent()
	if  parent.is_in_group("boat"):
		#print("CAMERA: returning boat")
		return parent
	print("CAMERA: not boat children, returning null")
	return null
	
func set_current():
	$Camera.current = true
