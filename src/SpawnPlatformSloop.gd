extends Spatial


func _on_UpgradeBuilding_upgraded():
	#get_parent().get_boat().unset_current()
	$CSGBox3.queue_free()
	$"SloopBoat/Boat".set_current()
