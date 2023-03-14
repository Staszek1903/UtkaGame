extends Control

#var is_paused:bool = false

var starved:bool = false

func starve():
	starved = true
	visible = true
	#get_tree().paused = true
	get_boat().unset_current()
	
func unstarve():
	starved = false
	visible = false

func _input(event):
	if not starved: return
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_ENTER:
			get_boat().delete_current()
			
			var man = $"/root/Root/SaveManager"
			if man: man.load_game()
			call_deferred("unstarve")
			
func get_boat():
	var pivot = get_viewport().get_camera().get_parent()
	assert(pivot.has_method("get_boat"))
	var boat = pivot.get_boat()
	return boat

	
