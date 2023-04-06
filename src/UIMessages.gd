extends VBoxContainer

export(int) var max_msg_count:int = 6
export(float) var msg_default_time:float = 5.0

onready var proto:Label = $Msg

var queue = []
var messages:Dictionary = {}
#var prev_message:String = ""

func display(msg:String, color:Color = Color.white):
#	if msg == prev_message: return
	var new_msg = proto.duplicate()
	new_msg.visible = true
	new_msg.modulate = color
	new_msg.text = msg
	if messages.size() < max_msg_count:
		messages[new_msg] = msg_default_time
		add_child(new_msg)
		if color == Color.red: $AudioBad.play()
	else:
		queue.push_back(new_msg)
		
#	prev_message = msg
	
	
func check_queue():
	while messages.size() < max_msg_count and queue.size() > 0:
		var new_msg = queue.pop_front()
		messages[new_msg] = msg_default_time
		add_child(new_msg)
		if new_msg.modulate == Color.red: $AudioBad.play()
	
func _process(delta):
	for msg in messages.keys():
		messages[msg] -= delta
		if messages[msg] < 0.0:
			msg.modulate.a -= delta
		if msg.modulate.a < 0.0:
			msg.queue_free()
			var _ignore = messages.erase(msg)
			check_queue()

	
#func _input(event):
#	if event is InputEventKey and event.pressed:
#		print("AAAA")
#		display("PRESSED: " + str(event.scancode))

