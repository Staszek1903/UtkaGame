tool
extends Area

signal selected

var is_mouse_hovering:bool = false

func _ready():
	connect("mouse_entered",self,"_on_mouse_entered")
	connect("mouse_exited",self,"_on_mouse_exited")
	connect("input_event",self,"_on_input_event")
	
func _process(delta):
	if is_mouse_hovering:
		$Mesh.rotate_y(delta* 3)
		
func _on_mouse_entered():
	is_mouse_hovering = true
	$SpotLight.visible = true
	#print("enter")

func _on_mouse_exited():
	is_mouse_hovering = false
	$SpotLight.visible = false
	#print("exit")
		
func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed: # and event.button_index == 0:
		print("CLICK: ", event.button_index, get_name())
		emit_signal("selected")
