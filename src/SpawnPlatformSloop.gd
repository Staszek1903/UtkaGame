extends Spatial

var sloop_boat_scene = preload("res://scenes/boats/SloopBoat.tscn")

func _on_UpgradeBuildingSloop_upgraded():
	get_parent().get_boat().delete_current()
	if $CSGBox3: $CSGBox3.queue_free()
	var sloop = sloop_boat_scene.instance()
	get_tree().get_root().add_child(sloop)
	sloop.global_transform = $SpawnPos.global_transform
	var boat = sloop.get_node("Boat")
	boat.set_current()

func remove_mockup():
	print("REMOOVE MOCKUP")
	cutter_mockup.queue_free()
