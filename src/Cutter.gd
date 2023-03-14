extends BasicBoat
#onready var keelForceOffset = $KeelForceOffset
onready var debug = $ForceDebug
onready var rudder = $Rudder

onready var anim = $"../AnimationPlayer"
onready var save_manager = $"/root/Root/SaveManager"

onready var initial_transform:Transform = global_transform

func _ready():
	assert(save_manager)
	assert(bom)
	assert(hinge_bom)
	save_manager.call_deferred("update_data",self)
	update_jib_trim()
	#assert(mooring_bow_l)
	#assert(mooring_bow_r)
	remove_mockups()
	
	heave_ljibsheet(0.0)
	heave_rjibsheet(0.0)
	
	
func remove_mockups():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("cutter_spawn", "remove_mockup")

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
#	print("caught items: ", catchable_bodies.size())
#	for i in catchable_bodies:
#		print("\t", i.items)
#		$CargoHold.add_items(i.items)
#		i.remove_catchable()
		#$CargoSlots.add_item(i)
	
func let_items_go():
	pass
#	if not $ItemTween: return
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

#func _on_CameraPivot_rotated(_angle:float, _pitch:float):
#	pass
	
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
	
func ease_sheets(delta):
	set_sail_trim(sail_trim + 10 * delta)

func heave_sheets(delta):
	set_sail_trim(sail_trim - 10 * delta)
	
func ease_mainsheet(delta):
	set_sail_trim(sail_trim + 10 * delta)
	return(sail_trim != 90.0)

func heave_mainsheet(delta):
	set_sail_trim(sail_trim - 10 * delta)
	return(sail_trim != 0.0)

var rjibsheet_trim:float = 0.0
var ljibsheet_trim:float = 0.0
onready var rjibsheet = $"Ropes/RJibSheet"
onready var ljibsheet = $"Ropes/LJibSheet"
export(float) var jibsheet_max_l = 3.6
export(float) var jibsheet_min_l = 1.05

const max_trim:float = 100.0

func ease_rjibsheet(delta):
	#print("ease_rjibsheet")
	rjibsheet_trim += 10 * delta
	rjibsheet_trim = clamp(rjibsheet_trim,0.0,max_trim)
	update_jib_trim()
	
	var rope_len = jibsheet_min_l \
	+ ((rjibsheet_trim/180.0)*(jibsheet_max_l-jibsheet_min_l))
	rjibsheet.length = 0.8 * rope_len
	
	print(rjibsheet_trim)
	return(rjibsheet_trim != max_trim)
	
func heave_rjibsheet(delta):
	#print("heave_rjibsheet")
	rjibsheet_trim -= 10 * delta
	rjibsheet_trim = clamp(rjibsheet_trim,0.0,max_trim)
	update_jib_trim()
	
	var rope_len = jibsheet_min_l \
	+ ((rjibsheet_trim/180.0)*(jibsheet_max_l-jibsheet_min_l))
	rjibsheet.length = 0.8 * rope_len
	print(rjibsheet_trim)
	return(rjibsheet_trim != 0.0)
	
func ease_ljibsheet(delta):
	#print("ease_ljibsheet")
	ljibsheet_trim += 10 * delta
	ljibsheet_trim = clamp(ljibsheet_trim,0.0,max_trim)
	update_jib_trim()
	
	var rope_len = jibsheet_min_l \
	+ ((ljibsheet_trim/180.0)*(jibsheet_max_l-jibsheet_min_l))
	ljibsheet.length = 0.8 * rope_len
	print(ljibsheet_trim)
	return(ljibsheet_trim != max_trim)
	
func heave_ljibsheet(delta):
	#print("heave_ljibsheet")
	ljibsheet_trim -= 10 * delta
	ljibsheet_trim = clamp(ljibsheet_trim,0.0,max_trim)
	update_jib_trim()
	
	var rope_len = jibsheet_min_l \
	+ ((ljibsheet_trim/180.0)*(jibsheet_max_l-jibsheet_min_l))
	ljibsheet.length = 0.8 * rope_len
	print(ljibsheet_trim)
	return(ljibsheet_trim != 0.0)

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

func consume_food_portion() -> bool:
	var food = $CargoHold.get_item_count("Food")
	if food == 0 : return false
	$CargoHold.withdraw_items({"Food": 1})
	return true

onready var floaters:Array = [ $FloaterBow, $FloaterStern,
	$FloaterPort, $FloaterStar ]

func set_floaters_height(h:float):
	for f in floaters:
		f.depthBeforeSubmerged = h
		
func set_floaters_enabled(en:bool):
	for f in floaters:
		f.enabled = en
		
func _on_sink():
	print("ON SINK RESPAWN")
	save_manager.load_game()
