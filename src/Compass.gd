extends Spatial

onready var arrow:Spatial = $Arrow
onready var tween:Tween = $Tween
#var mouse_pos:Vector3 = Vector3(1.0,0,0)

func _on_Area_input_event(_camera, _event, click_position, _click_normal, _shape_idx):
	#mouse_pos = click_position
	var target_vect = click_position - global_transform.origin
	var local_target_vect = global_transform.basis.xform_inv(target_vect)
	var angle = atan2(local_target_vect.x, local_target_vect.z)
	
	
	tween.remove_all()
	tween.interpolate_property(arrow, "rotation:y",
		arrow.rotation.y,
		angle,2,
		Tween.TRANS_ELASTIC,
		Tween.EASE_OUT)
	tween.start()
		
	#arrow.rotation.y = angle
