extends Control

signal satisfied

onready var key_label = $KeyIcon/Label
onready var message_label = $Label

#export(float, 0, 1) var hold_time = 0.0
#var hold_timer = 0.0

enum KeyList{
	Z = KEY_Z,
	Ctrl = KEY_CONTROL,
	W = KEY_W,
	S = KEY_S,
	A = KEY_A,
	D = KEY_D,
	LMB = 0
	RMB = 1
}

export(KeyList) var key:int setget set_key
export(HintIndicator.Points) var point = 0
#export(String) var key 
export(String) var message setget set_message

func _ready():
	set_key(key)
	set_message(message)
	add_to_group("key_hint")

func set_key(val: int):
	key = val
	if key_label:
		var index = KeyList.values().find(val)
		key_label.text = KeyList.keys()[index]

func set_message(val:String):
	message = val
	if message_label:
		message_label.text = val
		
func _input(event):
	if not visible: return
	if event is InputEventKey and event.pressed:
		#print("KEY_", event.scancode )
		if key == event.scancode:
			visible = false
			emit_signal("satisfied")
		elif event.scancode == KEY_ENTER:
			_on_last_satisfied()

func _on_prev_satisfied():
	visible = true
	get_tree().call_group("hint_indicator","set_hint_visible",
		point, true)
		
func _on_point_satisfied(_point:int):
	if point == _point:
		visible = false
		emit_signal("satisfied")
	
	
func _on_last_satisfied():
	print("deleting tutorial (ACTUALY NOT XD)")
	visible = false
	#get_tree().call_group("key_hint", "queue_free")
	#get_tree().call_group("hint_indicator", "queue_free")
