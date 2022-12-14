 extends Node

onready var boat = $"../Boat"

var current:bool = false setget set_current

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

