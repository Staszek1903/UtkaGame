extends BasicBoat

onready var floater = $FloaterBow
onready var floater2 = $FloaterStern
onready var floater3 = $FloaterPort
onready var floater4 = $FloaterStar
#onready var keelForceOffset = $KeelForceOffset
onready var debug = $ForceDebug
onready var rudder = $Rudder
#onready var mooring_bow_l = $"../MooringBowL"
#onready var mooring_bow_r = $"../MooringBowR"
#onready var mooring_bow_l_end = $"MooringBowLEnd"
#onready var mooring_bow_r_end = $"MooringBowREnd"

#export(float) var keel_force: float = 60.0

#onready var sail_trim = hinge_bom.get("angular_limit/upper") setget set_sail_trim

onready var initial_transform:Transform = global_transform

signal sink
signal water_level_changed(val)
const empying_max_rate:float = 0.01
var water_level:float = 0.0 setget set_water_level
signal hit_level_changed(val)
const repair_rate:float = 0.05
const max_hit_level:float = 3.0
var hit_level:float = 0.0 setget set_hit_level


func _ready():
	assert(bom)
	assert(hinge_bom)
	update_jib_trim()
	#assert(mooring_bow_l)
	#assert(mooring_bow_r)

func _physics_process(delta):
	update_water_level(delta)
	update_hit_level(delta)
	#update_moorings(delta)

#################################
# CATCHING ITEMS				#
#################################

var catchable_bodies = []
var items_to_be_caught = []
func _on_ItemCatchArea_body_entered(body):
	if body.is_in_group("catchable"): # body.get("items") != null:
		catchable_bodies.append(body)
		print("added catch item", body)

func _on_ItemCatchArea_body_exited(body):
	catchable_bodies.erase(body)
	
func catch_items():
	#if not $ItemTween: return
	#items_to_be_caught = catchable_bodies.duplicate()
	#for body in catchable_bodies:
	#	$ItemTween.interpolate_property(body, "global_transform:origin:y",
	#	global_transform.origin.y, global_transform.origin.y+4, 4)
	#$ItemTween.start()
	#print("catching")
	#yield($ItemTween, "tween_all_completed")
	print("caught items: ", catchable_bodies.size())
	for i in catchable_bodies:
		print("\t", i.items)
		$CargoHold.add_items(i.items)
		i.remove_catchable()
		#$CargoSlots.add_item(i)
	
func let_items_go():
	pass
#	if not $ItemTween: return
#	$ItemTween.remove_all()
#	items_to_be_caught = []
	
func throw_cargo():
	var node:RigidBody = $CargoSlots.remove_item()
	print("throwing: ", node)
	if not node: return
	get_tree().get_root().add_child(node)
	node.global_transform = $CargoDrop.global_transform
	node.linear_velocity = Vector3.ZERO
	#node.apply_central_impulse(Vector3.UP * 100)

func _on_CameraPivot_rotated(angle:float, pitch:float):
	pass

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
	#set_water_level(water_level + water_level_rate)
	if water_level > 1.0:
		emit_signal("sink")
		floater.enabled = false
		floater2.enabled = false
		floater3.enabled = false
		floater4.enabled = false
		$FloaterMast.enabled = false
		$SinkScreen.activate()
		
func respawn():
	get_tree().call_group("spawn_point", "respawn")

var end_game:bool = false
func end_game():
	end_game = true

func set_water_level(val):
	if end_game: return
	val = clamp(val, 0.0, 1.1)
	water_level = val
	#emit_signal("water_level_changed",val)

func update_hit_level(delta):
	if hit_level > 0.0:
		set_hit_level(hit_level-(repair_rate*delta))

func set_hit_level(val):
	val = clamp(val, 0, max_hit_level)
	hit_level = val
	emit_signal("hit_level_changed",val)

func receive_damage(_dmg:int = 1):
	hit_level += 1
	
func set_sail_trim(val: float):
	val = clamp(val, 0.0, 90.0)
	sail_trim = val
	hinge_bom.set("angular_limit/upper", val)
	hinge_bom.set("angular_limit/lower", -val)
	
func ease_sheets(delta):
	set_sail_trim(sail_trim + 10 * delta)

func heave_sheets(delta):
	set_sail_trim(sail_trim - 10 * delta)
	
func ease_mainsheet(delta):
	set_sail_trim(sail_trim + 10 * delta)

func heave_mainsheet(delta):
	set_sail_trim(sail_trim - 10 * delta)
	

var rjibsheet_trim:float = 90.0
var ljibsheet_trim:float = 90.0

func ease_rjibsheet(delta):
	print("ease_rjibsheet")
	rjibsheet_trim += 10 * delta
	rjibsheet_trim = clamp(rjibsheet_trim,0.0,180.0)
	update_jib_trim()
	
func heave_rjibsheet(delta):
	print("heave_rjibsheet")
	rjibsheet_trim -= 10 * delta
	rjibsheet_trim = clamp(rjibsheet_trim,0.0,180.0)
	update_jib_trim()
	
func ease_ljibsheet(delta):
	print("ease_ljibsheet")
	ljibsheet_trim += 10 * delta
	ljibsheet_trim = clamp(ljibsheet_trim,0.0,180.0)
	update_jib_trim()
	
func heave_ljibsheet(delta):
	print("heave_ljibsheet")
	ljibsheet_trim -= 10 * delta
	ljibsheet_trim = clamp(ljibsheet_trim,0.0,180.0)
	update_jib_trim()
	
func update_jib_trim():
	var zero_angle = 15.0
	var left_side_limit = min(-zero_angle + rjibsheet_trim,
		zero_angle + ljibsheet_trim)
	var right_side_limit = max(zero_angle - ljibsheet_trim,
		-zero_angle - rjibsheet_trim)
		
	if right_side_limit > left_side_limit:
		var avg = (right_side_limit + left_side_limit) * 0.5
		right_side_limit = avg - 0.01
		left_side_limit = avg + 0.01

	hinge_jib.set("angular_limit/upper", left_side_limit)
	hinge_jib.set("angular_limit/lower", right_side_limit)
	

func _on_sail_togle_trigger():
	bom.is_sail_up = not bom.is_sail_up
	print(bom.is_sail_up)
	jib.is_sail_up = bom.is_sail_up
	#if bom.is_sail_up:
		#$"../AnimationPlayer".play("fold")
	#else:
		#$"../AnimationPlayer".play_backwards("fold")

func consume_food_portion() -> bool:
	var food = $CargoHold.get_item_count("Food")
	if food == 0 : return false
	$CargoHold.withdraw_items({"Food": 1})
	return true
