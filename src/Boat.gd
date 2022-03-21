extends RigidBody

onready var floater = $FloaterBow
onready var floater2 = $FloaterStern
onready var floater3 = $FloaterPort
onready var floater4 = $FloaterStar
onready var keelForceOffset = $KeelForceOffset
onready var debug = $ForceDebug
onready var hinge: HingeJoint = $"../LowerSailHinge"
onready var hinge_jib: HingeJoint = $"../FokHinge"
onready var bom = $"../Bom"
onready var main_anim = $"../MainSailPlayer"
onready var jib = $"../fok_sheet"
onready var jib_anim = $"../FokAnimPlayer"
onready var bow_mooring = $"../BowMooring"
onready var stern_mooring = $"../SternPortMooring"
onready var inventory = $"/root/Root/Inventory"
onready var steering_label = $"../SteeringLabel"
onready var engine = $Engine

export(float) var keel_force: float = 60.0

onready var topenanta = hinge.get("angular_limit/upper") setget set_topenanta

onready var initial_transform:Transform = global_transform

signal sink
signal water_level_changed(val)
const empying_max_rate:float = 0.01
var water_level:float = 0.0 setget set_water_level
signal hit_level_changed(val)
const repair_rate:float = 0.05
const max_hit_level:float = 3.0
var hit_level:float = 0.0 setget set_hit_level

#var last_velocity:Vector3

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
			assert(f.is_valid())
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
						VALUE = "get_moorings_val"}),
	
]
var steering  setget set_steering
	
func dummy_func(delta):
		print("unbinded func")
func dummy_val() -> String:
	return "Dummy"

func _ready():
	assert(hinge)
	assert(bom)
	assert(main_anim)
	assert(jib)
	assert(jib_anim)
	assert(inventory)
	assert(steering_label)
	assert(engine)
	call_deferred("set_steering",steer_interfaces[current_steer])
	
func set_steering(st:SteerI):
	steering = st
	steering_label.set_interface_name(steering.name)
	steering_label.set_info(steering.get_val())
	
func set_topenanta(val: float):
	val = clamp(val, 0, 90)
	topenanta = val
	hinge.set("angular_limit/upper", val)
	hinge.set("angular_limit/lower", -val)
	hinge_jib.set("angular_limit/upper", val)
	hinge_jib.set("angular_limit/lower", -val)

func _physics_process(delta):
	update_cannon()
	update_water_level(delta)
	update_hit_level(delta)
	var global_pos = to_global(Vector3())

		
#	if Input.is_action_just_pressed("heave_main"):
#		if bom.is_sail_up : main_anim.play("MainReef")
#		else: main_anim.play_backwards("MainReef")
#		bom.is_sail_up = not bom.is_sail_up
#	if Input.is_action_just_pressed("heave_jib"):
#		if jib.is_sail_up : jib_anim.play("FokReef")
#		else: jib_anim.play_backwards("FokReef")
#		jib.is_sail_up = not jib.is_sail_up
#	if Input.is_action_just_pressed("dock"):
#		throw_moorings()
#	if Input.is_action_just_pressed("undock"):
#		retrieve_moorings()
#	if Input.is_action_pressed("heave_bow_moorin"):
#		bow_mooring.change_length(-delta)
#	if Input.is_action_pressed("heave_stern_mooring"):
#		stern_mooring.change_length(-delta)
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("action"):
		catch_items()
	if Input.is_action_just_released("action"):
		let_items_go()
	#print(hinge1.get("angular_limit/lower"))
#	if Input.is_action_pressed("motor_fwd"):
#		var floater_pos = floater.to_global(Vector3())
#		add_central_force(floater_pos - global_pos)
#	if Input.is_action_pressed("ui_right"):
#		var pos = floater2.to_global(Vector3()) - global_pos
#		var force = floater3.to_global(Vector3()) - global_pos
#		add_force(force,pos)
#		#add_central_force(force)
#	if Input.is_action_pressed("ui_left"):
#		var pos = floater2.to_global(Vector3()) - global_pos
#		var force = floater3.to_global(Vector3()) - global_pos
#		add_force(-force,pos)
#		#add_central_force(force)
	
	#VERTICAL DUMP
	var vel_vert = Vector3(
			0, linear_velocity.y, 0)
	add_central_force(-vel_vert * mass * 2)
	
	#KEEL
	var keel_pos = keelForceOffset.to_global(Vector3())
	var global_vel = linear_velocity
	var local_vel = global_transform.basis.xform_inv(global_vel)
	var local_vel_h  = Vector3(local_vel.x, 0,0)
	var global_vel_h = global_transform.basis.xform(local_vel_h)
	add_force(- mass * global_vel_h *delta * keel_force, keel_pos - global_pos)
	
	#GRAVITY
	var gravity_force = Vector3(0,-9.8,0)
	add_central_force(gravity_force * mass)
	
	debug.clear()
	debug.draw(vel_vert)
	debug.draw(global_vel_h)
	#last_velocity = linear_velocity
	
func _process(delta):
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

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode > KEY_0 and event.scancode < KEY_5:
			current_steer = event.scancode - 49
			set_steering(steer_interfaces[current_steer])
			steering_label.set_steered_interface(current_steer)

func ease_mainsheet(delta):
	set_topenanta(topenanta + 10 * delta)
	
func heave_mainsheet(delta):
	set_topenanta(topenanta - 10 * delta)
	
func get_mainsheet_val() -> String:
	return str(topenanta) + "\nW: Ease sheet\n S: Heave sheet"
	
func thurst_up(delta):
	engine.change_thrust(delta)

func thurst_down(delta):
	engine.change_thrust(-delta)
	
func engine_toggle(delta):
	engine.toggle_engine()
	
func engine_gear_change(delta):
	engine.change_gear()
	
func get_thurst_val() -> String:
	return "%s %s %.1f%% \n E: Toggle\n R: Gear\n W: Throttle up\n S: Toggle Down"%["ON" if engine.is_on else "OFF",
							engine.current_gear,
							engine.thrust * 100.0]

func toggle_haulyard(delta):
	if bom.is_sail_up : main_anim.play("MainReef")
	else: main_anim.play_backwards("MainReef")
	bom.is_sail_up = not bom.is_sail_up
	if jib.is_sail_up : jib_anim.play("FokReef")
	else: jib_anim.play_backwards("FokReef")
	jib.is_sail_up = not jib.is_sail_up
	
func heave_haulyards(delta):
	if not bom.is_sail_up : 
		main_anim.play_backwards("MainReef")
		jib_anim.play_backwards("FokReef")
		bom.is_sail_up = true
		jib.is_sail_up = true

func ease_haulyards(delta):
	if bom.is_sail_up : 
		main_anim.play("MainReef")
		jib_anim.play("FokReef")
		bom.is_sail_up = false
		jib.is_sail_up = false

func get_haulyard_val()->String:
	return "Sail: " + ("UP" if bom.is_sail_up else "DOWN") + "\n E: Toggle"
	
func get_moorings_val()->String:
	return "Moorings " + \
	 ("OUT" if bow_docked_point else "IN")  + \
	"\nE: throw moorings\n R: retrieve moorings"
	
func shoot():
	$Cannon.shoot()
	
func get_mooring_end(area) -> Spatial:
	if area == $SternArea:
		return $MooringEndStern as Spatial
	elif area == $BowArea:
		return $MooringEndBow as Spatial
	return null
	
func get_mooring_rope(area) -> Spatial:
	if area == $SternArea:
		return stern_mooring as Spatial
	elif area == $BowArea:
		return bow_mooring as Spatial
	return null

var bow_docking_point:Spatial = null
var stern_docking_point:Spatial = null
var bow_docked_point:Spatial = null
var stern_docked_point:Spatial = null

func _on_BowArea_area_entered(area):
	bow_docking_point = area.get_parent()
	bow_docking_point.indicator_visible = true

func _on_SternArea_area_entered(area):
	stern_docking_point = area.get_parent()
	stern_docking_point.indicator_visible = true

func _on_BowArea_area_exited(area):
	if area.get_parent() == bow_docking_point:
		bow_docking_point.indicator_visible = false
		bow_docking_point = null

func _on_SternArea_area_exited(area):
	if area.get_parent() == stern_docking_point:
		stern_docking_point.indicator_visible = false
		stern_docking_point = null

func throw_moorings(delta):
	if bow_docking_point:
		$Tween.interpolate_property($MooringEndBow,"global_transform",
			$MooringEndBow.global_transform, bow_docking_point.global_transform, 
			2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
		bow_docked_point = bow_docking_point
	if stern_docking_point:
		$Tween.interpolate_property($MooringEndStern,"global_transform",
			$MooringEndStern.global_transform, stern_docking_point.global_transform, 
			2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
		stern_docked_point = stern_docking_point
	$Tween.start()
	yield($Tween, "tween_all_completed")
	bow_mooring.set_length(-1)
	stern_mooring.set_length(-1)
	if bow_docked_point: 
		bow_docked_point.docked_rope_end = $MooringEndBow
		bow_docked_point.docked_rope = bow_mooring
	if stern_docked_point:
		stern_docked_point.docked_rope_end = $MooringEndStern
		stern_docked_point.docked_rope = stern_mooring
	
func retrieve_moorings(delta):
	if bow_docked_point:
		bow_docked_point.docked_rope_end = null
		bow_docked_point.docked_rope = null
		bow_docked_point = null
	if stern_docked_point:
		stern_docked_point.docked_rope_end = null
		stern_docked_point.docked_rope = null
		stern_docked_point = null
	$Tween.interpolate_property($MooringEndBow,"global_transform",
		$MooringEndBow.global_transform, $MooringEndBowConst.global_transform, 
		2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
	$Tween.interpolate_property($MooringEndStern,"global_transform",
		$MooringEndStern.global_transform, $MooringEndSternConst.global_transform, 
		2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	bow_mooring.set_length(-1)
	stern_mooring.set_length(-1)

var catchable_bodies = []
var items_to_be_caught = []
func _on_ItemCatchArea_body_entered(body):
	if body.get("item_name") != null:
		catchable_bodies.append(body)
		print("added ", body)

func _on_ItemCatchArea_body_exited(body):
	catchable_bodies.erase(body)
	
func catch_items():
	items_to_be_caught = catchable_bodies.duplicate()
	for body in catchable_bodies:
		$ItemTween.interpolate_property(body, "global_transform:origin:y",
		global_transform.origin.y, global_transform.origin.y+4, 1)
	$ItemTween.start()
	print("catching")
	yield($ItemTween, "tween_all_completed")
	print("caught items: ", items_to_be_caught.size())
	for i in items_to_be_caught: 
		print("\t", i.item_name)
		i.queue_free()
		inventory.add_item(i.item_name, 1)
	

func let_items_go():
	$ItemTween.remove_all()
	items_to_be_caught = []

func _on_CameraPivot_rotated(angle:float, pitch:float):
	cannon_angle = angle
	cannon_pitch = pitch
	
var cannon_angle:float = 0.0
var cannon_pitch:float = 0.0

func update_cannon():
	var canon = $Cannon
	var ind = canon.get_node("Crosshair")
	
	var basis:Basis = Basis(Vector3(0.0,cannon_angle,0.0))
	basis = basis.scaled(canon.global_transform.basis.get_scale())
	canon.global_transform.basis = basis
	canon.set_pitch(cannon_pitch)
	var dist = canon.get_range(cannon_pitch)
	ind.transform.origin.z = -dist*0.2

func update_water_level(delta):
	var basis:Basis = global_transform.basis
	var for_vect = basis.z
	var horizontal_angle = atan2(for_vect.x, for_vect.z)
	var up_vect:Vector3 = basis.y
	up_vect = up_vect.rotated(Vector3(0.0,1.0,0.0), -horizontal_angle);
	var tilt = abs(atan2(up_vect.x,up_vect.y))
	
	var spill_min = deg2rad(15)
	var spill_max = deg2rad(90)
	var normalized_spill = (tilt - spill_min) / (spill_max - spill_min)
	normalized_spill += 0.1 * hit_level
	var water_level_rate = clamp(normalized_spill,-empying_max_rate,1) * delta
	set_water_level(water_level + water_level_rate)
	if water_level > 1.0:
		emit_signal("sink")
		floater.enabled = false
		floater2.enabled = false
		floater3.enabled = false
		floater4.enabled = false
		$FloaterMast.enabled = false
		$SinkScreen.activate()
		
func respawn():
	mode = RigidBody.MODE_STATIC
	set_water_level(0.0)
	set_hit_level(0)
	inventory.clear_inventory()
	global_transform = initial_transform
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	floater.enabled = true
	floater2.enabled = true
	floater3.enabled = true
	floater4.enabled = true
	$FloaterMast.enabled = true
	engine_toggle(0)
	thurst_down(100)
	ease_haulyards(0)
	steering_label.set_info(steering.get_val())
	
	yield(get_tree().create_timer(1), "timeout")
	mode = RigidBody.MODE_RIGID
	

func set_water_level(val):
	val = clamp(val, 0.0, 1.1)
	water_level = val
	emit_signal("water_level_changed",val)

func update_hit_level(delta):
	if hit_level > 0.0:
		set_hit_level(hit_level-(repair_rate*delta))

func set_hit_level(val):
	val = clamp(val, 0, max_hit_level)
	hit_level = val
	emit_signal("hit_level_changed",val)

func receive_damage(dmg:int = 1):
	hit_level += 1
	

#func _integrate_forces(state):
#	for i in state.get_contact_count():
#		var name = state.get_contact_collider_object(i).get_name()
#		var vel = state.get_contact_collider_velocity_at_position(i)
#		print("HIT REPORTED(",i,"): ", name, " F: ", vel)
#		if vel.length() > 3.0:
#			set_hit_level(hit_level+1.0)
#
#
#func _on_Boat_body_entered(body):
#	print("BODY ENTERED: ", body.get_name())
