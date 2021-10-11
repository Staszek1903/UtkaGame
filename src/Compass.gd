extends Spatial

onready var arrow:Spatial = $Arrow

func _process(delta):
	var target_vect = Vector3.RIGHT
	var local_target_vect = global_transform.basis.xform_inv(target_vect)
	var angle = atan2(local_target_vect.x, local_target_vect.z)
	arrow.rotation.y = angle
