extends Particles

func _process(_delta):
	var camera = get_viewport().get_camera()
	global_transform.origin.x = camera.global_transform.origin.x
	global_transform.origin.z = camera.global_transform.origin.z
