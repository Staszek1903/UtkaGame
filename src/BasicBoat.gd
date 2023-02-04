extends RigidBody
class_name BasicBoat

onready var waterManager = $"/root/Root/WaterManager"
onready var islandManager = $"/root/Root/IslandsManager"
onready var water_bar = $"/root/Ui/WaterLevel"
onready var hunger_bar = $"/root/Ui/HungerLevel"
onready var player_control = $"../Control"
onready var cargo_hold = $CargoHold

onready var bom = $"../Bom"
onready var jib = $"../fok_sheet"

onready var keelForceOffset = $KeelForceOffset
onready var hinge_bom: HingeJoint = $"../LowerSailHinge"
onready var hinge_jib: HingeJoint = $"../FokHinge"

onready var sail_trim = hinge_bom.get("angular_limit/upper") setget set_sail_trim

export(float) var keel_force: float = 60.0
export(bool) var connect_ui:bool = false

var godmode:bool = false
const hunger_time:float = 240.0
var hunger:float = 0

var vip_slot:Spatial = null

func _ready():
	#assert(bom)
	assert(hunger_bar)
	assert(player_control)
	add_to_group("boat")
	if connect_ui:
		call_deferred("subscribe_to_indicators")
		water_bar.value = 0
		water_bar.set_hit_level(0)

func set_current():
	call_deferred("subscribe_to_indicators")
	$CameraPivot.set_current()
	$"../Control".current = true
	
func unset_current():
	$"../Control".current = false
	
func is_current() -> bool:
	return $"../Control".current
	
func delete_current():
	var points = $SteeringPointsCollection
	if points:
		for p in points.get_children():
			if p.has_method("request_undocking_to_end"):
				p.request_undocking_to_end(p.current_point)
				print("undocked before delete")
	get_parent().queue_free()
	
	
func get_boats(array:Array):
	array.append(self)

func subscribe_to_indicators():
	$"/root/Ui/Indicators".set_boat(self)

func _physics_process(delta):
	check_sinking()
	#print("B, ", self)
	#print(">>>>>>>>> Physics Proces")
	var global_pos = to_global(Vector3())
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
	
	#HUNGER
	if player_control.current and not godmode:
		update_hunger(delta)
	
	#WATER LEVEL
	if not godmode:
		update_water_level(delta)
		
func _on_sink():
	pass
		
func check_sinking():
	var global_pos = global_transform.origin
#	print(global_transform.origin.y \
#	- waterManager.wave(Vector2(global_pos.x, global_pos.z)))
	if global_transform.origin.y \
	- waterManager.wave(Vector2(global_pos.x, global_pos.z)) \
	+ islandManager.get_height_rel_to_camera(global_pos) \
	< -20.0:
		delete_current()
		_on_sink()
		print(get_parent().name,"  SUUUNK")

func set_sail_trim(_val: float):
	assert(false, "pure virtual function")
	
func consume_food_portion() -> bool:
	#assert(false, "pure virtual function")
	return false
	
func update_hunger(delta:float):
	hunger += delta
	if hunger > hunger_time:
		if consume_food_portion(): hunger = 0.0
	
	var starvation = hunger - hunger_time
	var hunger_val = 1.0 - (hunger / hunger_time)
	var starvation_val = 1.0 - (starvation / hunger_time)
	if starvation_val <= 0.0: get_tree().quit()
	hunger_bar.set_hunger_level(hunger_val)
	hunger_bar.set_starvation_level(starvation_val)
	
func board_the_vip(vip:Spatial):
	if vip_slot: return
	var p = vip.get_parent()
	if p: p.remove_child(vip)
	add_child(vip)
	vip.transform.origin = Vector3.ZERO
	vip_slot = vip
	
func get_vip():
	return vip_slot
	
func release_vip() -> Spatial:
	if not vip_slot: return null
	var vip = vip_slot
	remove_child(vip)
	vip_slot = null
	return vip
	
func get_camera() -> Spatial:
	var camera = $CameraPivot/Camera
	assert(camera is Camera)
	return camera

######################################################
#					WATER & HP						 #
######################################################

const empying_max_rate:float = 0.01
const bilge_pump_rate:float = 0.1
const repair_rate:float = 0.1
const max_hit_level:float = 3.0

signal sink

var water_level:float = 0.0 setget set_water_level
var hit_level:float = 0.0 setget set_hit_level

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
		set_floaters_enabled(false)
		emit_signal("sink")
		

func pump_bilge(delta):
	set_water_level(water_level - bilge_pump_rate * delta)
	
func respawn():
	get_tree().call_group("spawn_point", "respawn")

#var end_game:bool = false
#func end_game():
#	end_game = true

func set_water_level(val):
#	if end_game: return
	val = clamp(val, 0.0, 1.1)
	water_level = val
	if player_control.current:
		 water_bar.value = water_level
	set_floaters_height(0.5 + val * 4.0)

func set_floaters_height(_val:float):
	assert(false, "call to virtual method")

func set_floaters_enabled(_en:bool):
	assert(false, "call to virtual method")

var repair_amount:float = 0.0
func repair_hit_level(delta):
	print("repair")
	if not cargo_hold: return
	if repair_amount <= 0.0 \
	and cargo_hold.get_item_count("Wood") > 0:
		cargo_hold.withdraw_items({"Wood":1})
		repair_amount += 1

	if hit_level > 0.0 and repair_amount > 0.0:
		set_hit_level(hit_level-(repair_rate*delta))
		repair_amount -= repair_rate*delta

func set_hit_level(val):
	val = clamp(val, 0, max_hit_level)
	hit_level = val
	if player_control.current:
		water_bar.set_hit_level(val)
	

func receive_damage(dmg:int = 1):
	set_hit_level(hit_level + dmg)
	
func get_cargo() -> Node:
	return $CargoHold
