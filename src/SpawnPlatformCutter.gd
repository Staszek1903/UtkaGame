extends Spatial

var sloop_boat_scene = preload("res://scenes/boats/Cutter.tscn")
var lug_boat_mockup_scene = preload("res://scenes/boats/LugBoatMockup.tscn")
onready var cutter_mockup = $SpawnPos/CutterMockup
#
func _ready():
	add_to_group("cutter_spawn")
	call_deferred("move_mockup")

func move_mockup():
	var trans = cutter_mockup.global_transform
	cutter_mockup.get_parent().remove_child(cutter_mockup)
	get_tree().get_root().add_child(cutter_mockup)
	cutter_mockup.global_transform = trans
	
func remove_mockup():
	print("REMOOVE MOCKUP")
	if is_instance_valid(cutter_mockup):
		cutter_mockup.queue_free()

func _on_UpgradeBuildingCutter_upgraded():
	var trans = cutter_mockup.global_transform
	cutter_mockup.queue_free()
	
	var old_boat = get_parent().get_boat()
	var old_trans = old_boat.global_transform
	old_boat.delete_current()
	var lug_mockup = lug_boat_mockup_scene.instance()
	get_tree().get_root().get_node("Root").add_child(lug_mockup)
	lug_mockup.global_transform = old_trans
	
	var sloop = sloop_boat_scene.instance()
	get_tree().get_root().get_node("Root").add_child(sloop)
	sloop.global_transform = trans
	var boat = sloop.get_node("Boat")
	boat.set_current()
	
	var save_manager = $"/root/Root/SaveManager"
	save_manager.update_data(boat)
	save_manager.save_data()
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		remove_mockup()
