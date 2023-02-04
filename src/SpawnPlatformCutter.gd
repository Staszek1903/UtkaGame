extends Spatial

var sloop_boat_scene = preload("res://scenes/boats/Cutter.tscn")

func _on_UpgradeBuildingCutter_upgraded():
	get_parent().get_boat().unset_current()
	var sloop = sloop_boat_scene.instance()
	get_tree().get_root().add_child(sloop)
	sloop.global_transform = $SpawnPos.global_transform
	var boat = sloop.get_node("Boat")
	boat.set_current()
