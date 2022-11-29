extends Spatial


func _on_UpgradeBuilding2_upgraded():
	$CSGBox4.queue_free()
	$CSGBox5.queue_free()
	$Cutter/Boat.set_current()
