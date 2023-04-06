extends BasicBoat

#onready var floater = $FloaterBow
#onready var floater2 = $FloaterStern
#onready var floater3 = $FloaterPort
#onready var floater4 = $FloaterStar
#onready var keelForceOffset = $KeelForceOffset
onready var debug = $ForceDebug
onready var rudder = $Rudder
#onready var mooring_bow_l = $"../MooringBowL"
#onready var mooring_bow_r = $"../MooringBowR"
onready var mooring_bow_l_end = $"MooringBowLEnd"
onready var mooring_bow_r_end = $"MooringBowREnd"
onready var anim = $"../AnimationPlayer"
onready var save_manager = $"/root/Root/SaveManager"
#export(float) var keel_force: float = 60.0

#onready var sail_trim = hinge_bom.get("angular_limit/upper") setget set_sail_trim

onready var initial_transform:Transform = global_transform

func _ready():
	assert(bom)
	assert(hinge_bom)
	assert(save_manager)
	save_manager.call_deferred("update_data",self)
	set_sail_trim(10.0)
	
	anim.play("fold",-1,10.0,false)
#	assert(mooring_bow_l)
#	assert(mooring_bow_r)

#func _physics_process(delta):
#	update_water_level(delta)
#	update_hit_level(delta)
	#update_moorings(delta)

#################################
# CATCHING ITEMS				#
#################################

var catchable_bodies = []
var items_to_be_caught = []
func _on_ItemCatchArea_body_entered(body):
#	if body.is_in_group("catchable"): # body.get("items") != null:
#		catchable_bodies.append(body)
#		print("added catch item", body)
	if body.is_in_group("catchable"):
		var hold = $CargoHold
		print("caught items: ", body.items)
	#	for i in catchable_bodies:
		hold.add_items(body.items)
		$AudioLoot.play()
		body.remove_catchable()
		
#		for iname in body.items:
			

func _on_ItemCatchArea_body_exited(body):
	catchable_bodies.erase(body)
	
func catch_items():
	pass
	#if not $ItemTween: return
	#items_to_be_caught = catchable_bodies.duplicate()
	#for body in catchable_bodies:
	#	$ItemTween.interpolate_property(body, "global_transform:origin:y",
	#	global_transform.origin.y, global_transform.origin.y+4, 4)
	#$ItemTween.start()
	#print("catching")
	#yield($ItemTween, "tween_all_completed")
#	print("caught items: ", catchable_bodies.size())
#	for i in catchable_bodies:
#		print("\t", i.items)
#		$CargoHold.add_items(i.items)
#		i.remove_catchable()
#		#$CargoSlots.add_item(i)
	
func let_items_go():
	pass
	
func throw_cargo():
	var node:RigidBody = $CargoSlots.remove_item()
	print("throwing: ", node)
	if not node: return
	get_tree().get_root().add_child(node)
	node.global_transform = $CargoDrop.global_transform
	node.linear_velocity = Vector3.ZERO
	#node.apply_central_impulse(Vector3.UP * 100)

func _on_CameraPivot_rotated(_angle:float, _pitch:float):
	pass
	
onready var sheet = $"Ropes/MainSheet"
export(float) var sheet_max_l = 2.0
export(float) var sheet_min_l = 0.1
func set_sail_trim(val: float):
	val = clamp(val, 0.0, 90.0)
	sail_trim = val
	hinge_bom.set("angular_limit/upper", val)
	hinge_bom.set("angular_limit/lower", -val)
	
	#CALCULATE ROPE LENGTH
	var rope_len = sheet_min_l + ((val/90.0)*(sheet_max_l-sheet_min_l))
	sheet.length = 0.8 * rope_len # MAGIC NUMBER 0.8
#	sheet.length = 0.8 * sheet.atachmentNodeA.global_transform.origin.distance_to(
#		sheet.atachmentNodeB.global_transform.origin
#	)
	
func ease_sheets(delta):
	set_sail_trim(sail_trim + 10 * delta)
	return(sail_trim != 90.0)

func heave_sheets(delta):
	set_sail_trim(sail_trim - 10 * delta)
	return(sail_trim != 0.0)
	
var main_haulyard:float = 1.0
	
func heave_mainhaul(delta):
#	if bom.sail_amount < 0.5:
#		$"../AnimationPlayer".play_backwards("fold")
	main_haulyard -= 0.5*delta
	main_haulyard = clamp(main_haulyard, 0.0, 1.0)
	#print("HAUL: ", main_haulyard)
	anim.current_animation = "fold"
	anim.stop(false)
	anim.seek(main_haulyard, true)
	
	return (main_haulyard != 0.0)
	
func ease_mainhaul(delta):
#	if bom.sail_amount > 0.5:
#		$"../AnimationPlayer".play("fold")
	main_haulyard += 0.5*delta
	main_haulyard = clamp(main_haulyard, 0.0, 1.0)
	anim.current_animation = "fold"
	anim.stop(false)
	anim.seek(main_haulyard, true)
	
	return (main_haulyard != 1.0)


#func _on_sail_togle_trigger():
#	if bom.is_sail_up:
#		$"../AnimationPlayer".play("fold")
#	else:
#		$"../AnimationPlayer".play_backwards("fold")
		

func consume_food_portion() -> bool:
	var food = $CargoHold.get_item_count("Food")
	if food == 0 : return false
	$CargoHold.withdraw_items({"Food": 1})
	return true

onready var floaters:Array = [ $FloaterBow, $FloaterStern,
	$FloaterPort, $FloaterStar ]

func set_floaters_height(_val:float):
	pass

func set_floaters_enabled(en:bool):
	for f in floaters:
		f.enabled = en
	
func special():
	$"../AnimationPlayer".play("paddle")
	#apply_torque_impulse(Vector3.DOWN * 10.0)
	
func _on_sink():
	print("ON SINK RESPAWN")
	save_manager.load_game()
	
