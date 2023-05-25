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
			get_tree().paused = false
			is_paused = false
			visible = false
			
			#WHY DO I NEED TO REMOVE RESOURCES???
			var root = get_tree().get_root().get_node("Root") 
			for ch in root.get_children():
				#print("REMOVING: ", ch," name: ", ch.name)
				ch.queue_free()
			root.queue_free()
				
			var _ignore = get_tree().change_scene("res://scenes/Menu.tscn")
			
	
