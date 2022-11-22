extends Spatial

var is_functioning:bool = false

func _on_Area_body_entered(body):
	if body.name == "Boat" and is_functioning:
		$AnimationPlayer.play("open")

func _on_Area_body_exited(body):
	if body.name == "Boat" and is_functioning:
		$AnimationPlayer.play_backwards("open")


func _on_BridgeControlPort_repair_bridge():
	is_functioning = true


func _on_AutoRepairArea_body_entered(body):
	if body.name == "Boat":
		_on_BridgeControlPort_repair_bridge()
