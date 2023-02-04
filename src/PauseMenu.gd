extends Control

var is_paused:bool = false

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_ESCAPE:
			is_paused = not is_paused
			print("PAUSED: ", is_paused)
			visible = is_paused
			get_tree().paused = is_paused
		
		if event.scancode == KEY_ENTER and is_paused:
			get_tree().quit()

	
