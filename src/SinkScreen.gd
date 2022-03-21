extends CanvasLayer

var active:bool = false
var ready_to_respawn:bool = false
var time:float = 0.0
onready var control = $Control

func activate():
	active= true
	control.visible = true

func _process(delta):
	if active:
		time += delta/4.0
		
		if time>1:
			active = false
			ready_to_respawn = true
			control.modulate.a = 1.0
			return
		control.modulate.a = time
		
func _input(event):
	if ready_to_respawn and event is InputEventKey:
			control.visible = false
			active = false
			ready_to_respawn = false
			time = 0.0
			get_parent().respawn()
