extends Label


func _input(event):
	if event is InputEventMouseMotion:
		rect_position = event.position + Vector2(10,0)
