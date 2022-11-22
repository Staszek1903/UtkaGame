extends Spatial
class_name Vip

enum Id{
	FOOD_PRODUCTION,
	WOOD_PRODUCTION,
	FABRIC_PRODUCTION,
	STEEL_PRODUCTION
}

export(Id) var unlock_id = 0

func _on_UpgradeBuilding_upgraded():
	var boat:Spatial = get_parent().get_boat()
	boat.board_the_vip(self)
	$AnimationPlayer.play("Idle")
	
#func _input(event):
#	if event is InputEventKey and event.pressed:
#		if event.scancode == KEY_L:
#			_on_UpgradeBuilding_upgraded()
