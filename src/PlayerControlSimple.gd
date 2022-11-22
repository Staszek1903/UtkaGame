extends Node

onready var boat = $"../Boat"
#onready var steering_label = $"../SteeringLabel"
#
var current:bool = false setget set_current
#
#var steering  setget set_steering
#
func _ready():
	assert(boat)
#	call_deferred("set_steering",steer_interfaces[current_steer])
	add_to_group("steering")
	set_current(true)

func set_current(val:bool):
	if val: get_tree().call_group("steering", "clear_current")
	call_deferred("set_this_current")

func clear_current():
	current = false

func set_this_current():
	current = true


func _process(delta):
	if not current: return

	if Input.is_action_pressed("ease"):
		ease_sheets(delta)
	if Input.is_action_pressed("heave"):
		heave_sheets(delta)
	if Input.is_action_just_pressed("toggle"):
		print(OS.get_window_size())
	if Input.is_action_just_pressed("togle_alt"):
		pass

#	if Input.is_action_just_pressed("shoot"):
#		boat.shoot()
	if Input.is_action_just_pressed("action"):
		boat.catch_items()
	if Input.is_action_just_released("action"):
		boat.let_items_go()

	if Input.is_action_pressed("rudder_right"):
		boat.rudder.change_angle(delta)
	if Input.is_action_pressed("rudder_left"):
		boat.rudder.change_angle(-delta)


func ease_sheets(delta):
	boat.set_sail_trim(boat.sail_trim + 10 * delta)

func heave_sheets(delta):
	boat.set_sail_trim(boat.sail_trim - 10 * delta)

func get_mainsheet_val() -> String:
	return str(boat.sail_trim) + "\nW: Ease sheet\n S: Heave sheet"

#func get_moorings_val()->String:
#	return "Moorings " + \
#	 ("OUT" if boat.docked else "IN")  + \
#	"\nE: throw moorings\nR: retrieve moorings \nS: heave mooring"
#
#func throw_moorings(_delta):
#	boat.throw_mooring()
##	if bow_docking_point:
##		$Tween.interpolate_property($MooringEndBow,"global_transform",
##			$MooringEndBow.global_transform, bow_docking_point.global_transform, 
##			2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
##		bow_docked_point = bow_docking_point
##	if stern_docking_point:
##		$Tween.interpolate_property($MooringEndStern,"global_transform",
##			$MooringEndStern.global_transform, stern_docking_point.global_transform, 
##			2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
##		stern_docked_point = stern_docking_point
##	$Tween.start()
##	yield($Tween, "tween_all_completed")
##	bow_mooring.set_length(-1)
##	stern_mooring.set_length(-1)
##	if bow_docked_point: 
##		bow_docked_point.docked_rope_end = $MooringEndBow
##		bow_docked_point.docked_rope = bow_mooring
##	if stern_docked_point:
##		stern_docked_point.docked_rope_end = $MooringEndStern
##		stern_docked_point.docked_rope = stern_mooring
#
#func retrieve_moorings(_delta):
#	boat.retrieve_mooring()
##	if bow_docked_point:
##		bow_docked_point.docked_rope_end = null
##		bow_docked_point.docked_rope = null
##		bow_docked_point = null
##	if stern_docked_point:
##		stern_docked_point.docked_rope_end = null
##		stern_docked_point.docked_rope = null
##		stern_docked_point = null
##	$Tween.interpolate_property($MooringEndBow,"global_transform",
##		$MooringEndBow.global_transform, $MooringEndBowConst.global_transform, 
##		2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
##	$Tween.interpolate_property($MooringEndStern,"global_transform",
##		$MooringEndStern.global_transform, $MooringEndSternConst.global_transform, 
##		2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
##	$Tween.start()
##	yield($Tween, "tween_all_completed")
##	bow_mooring.set_length(-1)
##	stern_mooring.set_length(-1)
#
#func heave_mooring(delta):
#	boat.heave_mooring(delta)
#
#func throw_cargo(_delta):
#	boat.throw_cargo()
