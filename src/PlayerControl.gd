extends Node

onready var boat = $"../Boat"
onready var steering_label = $"../SteeringLabel"

var current:bool = false setget set_current

var steering  setget set_steering

func _ready():
	assert(boat)
	call_deferred("set_steering",steer_interfaces[current_steer])
	add_to_group("steering")
	set_current(true)

func set_current(val:bool):
	if val: get_tree().call_group("steering", "clear_current")
	call_deferred("set_this_current")

func clear_current():
	current = false
	steering_label.visible = false
	
func set_this_current():
	current = true
	steering_label.visible = true

func dummy_func(_delta):
		print("unbinded func")
func dummy_val() -> String:
	return "Dummy"

class SteerI:
	var name:String
	var funcs:Dictionary
	var delta:float = 0.0
	func call(i:String):
		funcs[i].call_func(delta)
	func get_val():
		return funcs["VALUE"].call_func()
		
func sif(name:String , funcs:Dictionary) -> SteerI:
	var sif = SteerI.new()
	sif.name = name
	var dummy = funcref(self, "dummy_func")
	sif.funcs = { EASE = dummy, HEAVE = dummy,
					TOGGLE = dummy, ALT = dummy,
					VALUE = funcref(self, "dummy_val")}
	for key in funcs:
		if sif.funcs.has(key):
			var f = funcref(self, funcs[key])
			assert(f.is_valid(), funcs[key]+ " isnt valid function")
			sif.funcs[key] = f
	return sif
	
var current_steer:int = 0
var steer_interfaces = [
	sif("Main Sheet", {EASE = "ease_mainsheet", 
						HEAVE = "heave_mainsheet",
						VALUE = "get_mainsheet_val"}),
	sif("Engine", {EASE = "thurst_up",
					HEAVE = "thurst_down",
					TOGGLE = "engine_toggle",
					ALT = "engine_gear_change",
					VALUE = "get_thurst_val"}),
	sif("Haulyard", {TOGGLE = "toggle_haulyard",
						EASE = "ease_haulyards", 
						HEAVE = "heave_haulyards",
						VALUE = "get_haulyard_val"}),
	sif("Moorings", {TOGGLE = "throw_moorings",
						ALT = "retrieve_moorings",
						HEAVE = "heave_mooring",
						VALUE = "get_moorings_val"}),
	sif("Cargo", {TOGGLE = "throw_cargo"})
]

func set_steering(st:SteerI):
	steering = st
	
	if not current: return
	steering_label.set_interface_name(steering.name)
	steering_label.set_info(steering.get_val())
	
func _process(delta):
	if not current: return
	if Input.is_action_just_pressed("change_device"):
		current_steer += 1
		current_steer %= steer_interfaces.size()
		set_steering(steer_interfaces[current_steer])
		steering_label.set_steered_interface(current_steer)
	
	steering.delta = delta
	if Input.is_action_pressed("ease"):
		steering.call("EASE")
		steering_label.set_info(steering.get_val())
	if Input.is_action_pressed("heave"):
		steering.call("HEAVE")
		steering_label.set_info(steering.get_val())
	if Input.is_action_just_pressed("toggle"):
		steering.call("TOGGLE")
		steering_label.set_info(steering.get_val())
	if Input.is_action_just_pressed("togle_alt"):
		steering.call("ALT")
		steering_label.set_info(steering.get_val())


	if Input.is_action_just_pressed("shoot"):
		boat.shoot()
	if Input.is_action_just_pressed("action"):
		boat.catch_items()
	if Input.is_action_just_released("action"):
		boat.let_items_go()
		
	if Input.is_action_pressed("rudder_right"):
		boat.rudder.change_angle(delta)
		
	if Input.is_action_pressed("rudder_left"):
		boat.rudder.change_angle(-delta)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode > KEY_0 and event.scancode <= (KEY_0+steer_interfaces.size()):
			current_steer = event.scancode - 49
			set_steering(steer_interfaces[current_steer])
			steering_label.set_steered_interface(current_steer)
			
func ease_mainsheet(delta):
	boat.set_sail_trim(boat.sail_trim + 10 * delta)
	
func heave_mainsheet(delta):
	boat.set_sail_trim(boat.sail_trim - 10 * delta)
	
func get_mainsheet_val() -> String:
	return str(boat.sail_trim) + "\nW: Ease sheet\n S: Heave sheet"
	
func thurst_up(delta):
	boat.engine.change_thrust(delta)

func thurst_down(delta):
	boat.engine.change_thrust(-delta)
	
func engine_toggle(_delta):
	boat.engine.toggle_engine()
	
func engine_gear_change(_delta):
	boat.engine.change_gear()
	
func get_thurst_val() -> String:
	return "%s %s %.1f%% \n E: Toggle\n R: Gear\n W: Throttle up\n S: Toggle Down"%["ON" if boat.engine.is_on else "OFF",
							boat.engine.current_gear,
							boat.engine.thrust * 100.0]

func toggle_haulyard(_delta):
	if boat.bom.is_sail_up : boat.main_anim.play("MainReef")
	else: boat.main_anim.play_backwards("MainReef")
	boat.bom.is_sail_up = not boat.bom.is_sail_up
	if boat.jib.is_sail_up : boat.jib_anim.play("FokReef")
	else: boat.jib_anim.play_backwards("FokReef")
	boat.jib.is_sail_up = not boat.jib.is_sail_up
	
func heave_haulyards(_delta):
	if not boat.bom.is_sail_up : 
		boat.main_anim.play_backwards("MainReef")
		boat.jib_anim.play_backwards("FokReef")
		boat.bom.is_sail_up = true
		boat.jib.is_sail_up = true

func ease_haulyards(_delta):
	if boat.bom.is_sail_up : 
		boat.main_anim.play("MainReef")
		boat.jib_anim.play("FokReef")
		boat.bom.is_sail_up = false
		boat.jib.is_sail_up = false

func get_haulyard_val()->String:
	return "Sail: " + ("UP" if boat.bom.is_sail_up else "DOWN") + "\n E: Toggle"
	
func get_moorings_val()->String:
	return "Moorings " + \
	 ("OUT" if boat.docked else "IN")  + \
	"\nE: throw moorings\nR: retrieve moorings \nS: heave mooring"

func throw_moorings(_delta):
	boat.throw_mooring()
#	if bow_docking_point:
#		$Tween.interpolate_property($MooringEndBow,"global_transform",
#			$MooringEndBow.global_transform, bow_docking_point.global_transform, 
#			2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
#		bow_docked_point = bow_docking_point
#	if stern_docking_point:
#		$Tween.interpolate_property($MooringEndStern,"global_transform",
#			$MooringEndStern.global_transform, stern_docking_point.global_transform, 
#			2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
#		stern_docked_point = stern_docking_point
#	$Tween.start()
#	yield($Tween, "tween_all_completed")
#	bow_mooring.set_length(-1)
#	stern_mooring.set_length(-1)
#	if bow_docked_point: 
#		bow_docked_point.docked_rope_end = $MooringEndBow
#		bow_docked_point.docked_rope = bow_mooring
#	if stern_docked_point:
#		stern_docked_point.docked_rope_end = $MooringEndStern
#		stern_docked_point.docked_rope = stern_mooring
	
func retrieve_moorings(_delta):
	boat.retrieve_mooring()
#	if bow_docked_point:
#		bow_docked_point.docked_rope_end = null
#		bow_docked_point.docked_rope = null
#		bow_docked_point = null
#	if stern_docked_point:
#		stern_docked_point.docked_rope_end = null
#		stern_docked_point.docked_rope = null
#		stern_docked_point = null
#	$Tween.interpolate_property($MooringEndBow,"global_transform",
#		$MooringEndBow.global_transform, $MooringEndBowConst.global_transform, 
#		2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
#	$Tween.interpolate_property($MooringEndStern,"global_transform",
#		$MooringEndStern.global_transform, $MooringEndSternConst.global_transform, 
#		2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
#	$Tween.start()
#	yield($Tween, "tween_all_completed")
#	bow_mooring.set_length(-1)
#	stern_mooring.set_length(-1)

func heave_mooring(delta):
	boat.heave_mooring(delta)
	
func throw_cargo(_delta):
	boat.throw_cargo()
