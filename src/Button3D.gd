extends StaticBody


func _on_Button3D_input_event(camera, event, click_position, click_normal, shape_idx):
	pass # Replace with function body.


func _on_Button3D_mouse_entered():
	$CollisionShape.translation.y = 0.1
	print("has mouse")


func _on_Button3D_mouse_exited():
	$CollisionShape.translation.y = 0.0
	print("has no mouse")
