extends Area

export(int) var mouse_button = BUTTON_LEFT

signal pressed
signal released
signal mouse_hoover(is_hoovering)
signal change_visible

var has_mouse: bool = false
var is_pressed:bool = false

export(NodePath) var indicator:NodePath = ""
onready var ind:Node = $Indicator

var audio_hover: AudioStreamPlayer = null
var audio_click: AudioStreamPlayer = null

var active:bool = true setget set_active

func _ready():
	if has_node(indicator):
		ind  = get_node(indicator)
		
	if has_node("AudioHover"):
		audio_hover = get_node("AudioHover")
	if has_node("AudioClick"):
		audio_click = get_node("AudioClick")
		
	
	var _error
	if not is_connected("mouse_entered",self,"_on_mouse_entered"):
		_error = connect("mouse_entered",self,"_on_mouse_entered")
		_error = connect("mouse_exited",self,"_on_mouse_exited")
		#_error = connect("input_event",self,"_on_input_event")

func set_active(val:bool):
	active = val
	if not val:
		_on_mouse_exited()
		ind.visible = false

func _on_mouse_entered():
	if not active: return
	has_mouse = true
	emit_signal("mouse_hoover",has_mouse)
	ind.visible = true
	if audio_hover: audio_hover.play()


func _on_mouse_exited():
	if not has_mouse: return
	has_mouse = false
	emit_signal("mouse_hoover",has_mouse)
	ind.visible = false
	if is_pressed:
		is_pressed = false
		emit_signal("released")


#func _on_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
#	#print(event)
	


func _input(event):
	if not active: return
	if event is InputEventKey and event.scancode == KEY_CONTROL:
		ind.visible = event.pressed
		emit_signal("change_visible", event.pressed)
	elif event is InputEventMouseButton and event.pressed \
	and event.button_index == mouse_button \
	and has_mouse:
		is_pressed = true
		emit_signal("pressed")
		if audio_click: audio_click.play()
		#print("pressed")
#	elif event is InputEventMouseMotion:
#		ind.visible = true	
	elif event is InputEventMouseButton and not event.pressed \
	and event.button_index == mouse_button \
	and has_mouse:
		is_pressed = false
		emit_signal("released")
