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
		
	if prev_key_pressed != key_pressed:
		press_time = 0.0
		prev_key_pressed = key_pressed
	
	if key_pressed >= 0:
		press_time += delta
		if press_time > press_time_max:
			assign_steering_point(key_pressed)
			press_time = 0.0
		
const press_time_max:float = 1.0
var press_time:float = 0.0
var prev_key_pressed: int = -1
var key_pressed:int = -1

func _input(event):
	if not current: return
	
	if event is InputEventKey:
		var key = event.scancode
		if key < KEY_0 or key > KEY_9: return
		if event.pressed:
			key_pressed = key
		else:
			change_steering_point(key_pressed)
			key_pressed = -1
			
var points_asigned:Dictionary = {}
			
func change_steering_point(_key_pressed:int):
	if _key_pressed in points_asigned:
		steering_points.set_steering_point(
			points_asigned[_key_pressed]
			)
		print("quicked to "+str(_key_pressed))

func assign_steering_point(_key_pressed:int):
	points_asigned[_key_pressed] = \
		steering_points.current_steering_point
		
	print("asigned "+str(_key_pressed))
