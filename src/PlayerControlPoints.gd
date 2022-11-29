extends Node

onready var boat = $"../Boat"
onready var steering_points = $"../Boat/SteeringPointsCollection"

var current:bool = false setget set_current

var points_binds = [null,null,null,null]

func _ready():
	assert(boat)
	assert(steering_points)

	add_to_group("steering")
	set_current(true)

func set_current(val:bool):
	if val: get_tree().call_group("steering", "clear_current")
	call_deferred("set_this_current")
	
	steering_points.disable = not val

func clear_current():
	current = false
	steering_points.disable = true

func set_this_current():
	current = true
	steering_points.disable = false
	


func _process(delta):
	if not current: return

	if Input.is_action_pressed("ease"):
		steering_points.steer_ease(delta)
	if Input.is_action_pressed("heave"):
		steering_points.steer_heave(delta)
	if Input.is_action_just_pressed("toggle"):
		steering_points.scroll_point(1)
	if Input.is_action_just_pressed("togle_alt"):
		steering_points.scroll_point(-1)

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
