extends Control

func _input(event):
	if event is InputEventKey \
	and event.scancode == KEY_F1 \
	and event.pressed:
		$Panel.visible = not $Panel.visible
		$VBoxContainer.visible = not $VBoxContainer.visible
