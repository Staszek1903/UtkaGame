extends CSGCylinder


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		visible = event.pressed
