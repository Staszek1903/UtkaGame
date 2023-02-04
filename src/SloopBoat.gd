extends BasicBoat

#onready var floater = $FloaterBow
#onready var floater2 = $FloaterStern
#onready var floater3 = $FloaterPort
#onready var floater4 = $FloaterStar
#onready var keelForceOffset = $KeelForceOffset
onready var debug = $ForceDebug
onready var rudder = $Rudder
onready var anim = $"../AnimationPlayer"
onready var save_manager = $"/root/Root/SaveManager"

#export(float) var keel_force: float = 60.0

#onready var sail_trim = hinge_bom.get("angular_limit/upper") setget set_sail_trim

onready var initial_transform:Transform = global_transform

func _ready():
	assert(bom)
	assert(hinge_bom)
	assert(save_manager)
	update_jib_trim()
	save_manager.call_deferred("update_data",self)
#	$Crew.spawn()

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
 # body.get("items") != null:
#		catchable_bodies.append(body)
#		print("added catch item", body)
	if body.is_in_group("catchable"):
		print("caught items: ", body.items)
	#	for i in catchable_bodies:
		$CargoHold.add_items(body.items)
		body.remove_catchable()

func _on_ItemCatchArea_body_exited(body):
	catchable_bodies.erase(body)
	
func catch_items():
	pass
#	items_to_be_caught = catchable_bodies.duplicate()
#	for body in catchable_bodies:
#		$ItemTween.interpolate_property(body, "global_transform:origin:y",
#		global_transform.origin.y, global_transform.origin.y+4, 4)
#	$ItemTween.start()
#	print("catching")
#	yield($ItemTween, "tween_all_completed")
#	print("caught items: ", items_to_be_caught.size())
#	for i in items_to_be_caught: 
#		print("\t", i.item)
#		$CargoSlots.add_item(i)
#	items_to_be_caught = []
	
func let_items_go():
	pass
#	$ItemTween.remove_all()
#	items_to_be_caught = []
	
#func throw_cargo():
#	var node:RigidBody = $CargoSlots.remove_item()
#	print("throwing: ", node)
#	if not node: return
#	get_tree().get_root().add_child(node)
#	node.global_transform = $CargoDrop.global_transform
#	node.linear_velocity = Vector3.ZERO
	#node.apply_central_impulse(Vector3.UP * 100)

func _on_CameraPivot_rotated(_angle:float, _pitch:float):
	pass

onready var sheet = $"Ropes/MainSheet"
export(float) var sheet_max_l = 3.6
export(float) var sheet_min_l = 1.05
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
	
func ease_mainsheet(delta):
	set_sail_trim(sail_trim + 10 * delta)

func heave_mainsheet(delta):
	set_sail_trim(sail_trim - 10 * delta)
	

var rjibsheet_trim:float = 90.0
var ljibsheet_trim:float = 90.0
onready var rjibsheet = $"Ropes/RJibSheet"
onready var ljibsheet = $"Ropes/LJibSheet"
export(float) var jibsheet_max_l = 3.6
export(float) var jibsheet_min_l = 1.05

func ease_rjibsheet(delta):
	#print("ease_rjibsheet")
	rjibsheet_trim += 10 * delta
	rjibsheet_trim = clamp(rjibsheet_trim,0.0,180.0)
	update_jib_trim()
	
	var rope_len = jibsheet_min_l \
	+ ((rjibsheet_trim/180.0)*(jibsheet_max_l-jibsheet_min_l))
	rjibsheet.length = 0.8 * rope_len
	
func heave_rjibsheet(delta):
	#print("heave_rjibsheet")
	rjibsheet_trim -= 10 * delta
	rjibsheet_trim = clamp(rjibsheet_trim,0.0,180.0)
	update_jib_trim()
	
	var rope_len = jibsheet_min_l \
	+ ((rjibsheet_trim/180.0)*(jibsheet_max_l-jibsheet_min_l))
	rjibsheet.length = 0.8 * rope_len
	
func ease_ljibsheet(delta):
	#print("ease_ljibsheet")
	ljibsheet_trim += 10 * delta
	ljibsheet_trim = clamp(ljibsheet_trim,0.0,180.0)
	update_jib_trim()
	
	var rope_len = jibsheet_min_l \
	+ ((ljibsheet_trim/180.0)*(jibsheet_max_l-jibsheet_min_l))
	ljibsheet.length = 0.8 * rope_len
	
func heave_ljibsheet(delta):
	#print("heave_ljibsheet")
	ljibsheet_trim -= 10 * delta
	ljibsheet_trim = clamp(ljibsheet_trim,0.0,180.0)
	update_jib_trim()
	
	var rope_len = jibsheet_min_l \
	+ ((ljibsheet_trim/180.0)*(jibsheet_max_l-jibsheet_min_l))
	ljibsheet.length = 0.8 * rope_len

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
	
var main_haulyard:float = 1.0
	
func heave_mainhaul(delta):
#	if bom.sail_amount < 0.5:
#		$"../AnimationPlayer".play_backwards("fold")
	main_haulyard -= 0.5*delta
	main_haulyard = clamp(main_haulyard, 0.0, 1.0)
	print("HAUL: ", main_haulyard)
	anim.current_animation = "fold"
	anim.stop(false)
	anim.seek(main_haulyard, true)
	
func ease_mainhaul(delta):
#	if bom.sail_amount > 0.5:
#		$"../AnimationPlayer".play("fold")
	main_haulyard += 0.5*delta
	main_haulyard = clamp(main_haulyard, 0.0, 1.0)
	anim.current_animation = "fold"
	anim.stop(false)
	anim.seek(main_haulyard, true)

var jib_haulyard:float = 1.0

func heave_jibhaul(delta):
	jib_haulyard -= 0.5*delta
	jib_haulyard = clamp(jib_haulyard, 0.0, 1.0)
	anim.current_animation = "jib_fold"
	anim.stop(false)
	anim.seek(jib_haulyard, true)
	
func ease_jibhaul(delta):
	jib_haulyard += 0.5*delta
	jib_haulyard = clamp(jib_haulyard, 0.0, 1.0)
	anim.current_animation = "jib_fold"
	anim.stop(false)
	anim.seek(jib_haulyard, true)
		
######################
## MOORING			#
######################
#
#var mooring_l_heave:bool = false
#var mooring_r_heave:bool = false
#var active_mooring_end = null
#
#func _on_MooringTriggerL_pressed():
#	if mooring_bow_l_end.visible:
#		active_mooring_end = mooring_bow_l_end
#	else:
#		mooring_l_heave = true
#
#func _on_MooringTriggerR_pressed():
#	if mooring_bow_r_end.visible:
#		active_mooring_end = mooring_bow_r_end
#	else:
#		mooring_r_heave = true
#
#func _on_MooringTriggerL_released():
#	mooring_l_heave = false
#
#func _on_MooringTriggerR_released():
#	mooring_r_heave = false
#
#func request_docking_to_point(point:Node):
#	if active_mooring_end:
#		point.set_docked_rope_end(active_mooring_end)
#		active_mooring_end.visible = false
#		active_mooring_end = null
#
#func request_undocking_to_end(end:Node):
#	end.visible = true
#	end.global_transform = $MooringBowEndConst.global_transform
#
#func update_moorings(delta):
#	if mooring_l_heave: mooring_bow_l.apply_force(delta*100)
#	if mooring_r_heave: mooring_bow_r.apply_force(delta*100)

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
	
func _on_sink():
	print("ON SINK RESPAWN")
	save_manager.load_game()
