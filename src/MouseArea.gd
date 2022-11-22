extends Area

signal pressed
signal released

var has_mouse: bool = false
var is_pressed:bool = false
onready var ind:Node = $Indicator

func _ready():
	connect("mouse_entered",self,"_on_mouse_entered")
	connect("mouse_exited",self,"_on_mouse_exited")
	connect("input_event",self,"_on_input_event")


func _on_mouse_entered():
	has_mouse = true
	ind.visible = true


func _on_mouse_exited():
	has_mouse = false
	ind.visible = false
	if is_pressed:
		is_pressed = false
		emit_signal("released")


func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	#print(event)
	if event is InputEventMouseButton and event.pressed:
		is_pressed = true
		emit_signal("pressed")
		#print("pressed")
#	elif event is InputEventMouseMotion:
#		ind.visible = true	
	elif event is InputEventMouseButton and not event.pressed:
		is_pressed = false
		emit_signal("released")
