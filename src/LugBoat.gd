extends BasicBoat

export(float) var front_wave_offset:float = 1 setget set_front_wave_offset
export(float) var front_scale:float = 0.15 setget set_front_scale
export(float) var trail_radius:float = 25 setget set_trail_radius
export(float) var trail_segment_length = 35 setget set_trail_segment_length
#export(float) var front_scale_rate:float = 0.4 setget set_front_scale_rate

#onready var floater = $FloaterBow
#onready var floater2 = $FloaterStern
#onready var floater3 = $FloaterPort
#onready var floater4 = $FloaterStar
#onready var keelForceOffset = $KeelForceOffset
onready var debug = $ForceDebug
onready var rudder = $Rudder
onready var bow_particlesL = $BowParticlesL
onready var bow_particlesR = $BowParticlesR
#onready var mooring_bow_l = $"../MooringBowL"
#onready var mooring_bow_r = $"../MooringBowR"
onready var mooring_bow_l_end = $"MooringBowLEnd"
onready var mooring_bow_r_end = $"MooringBowREnd"
onready var anim:AnimationPlayer = $"../AnimationPlayer"
onready var save_manager = $"/root/Root/SaveManager"
onready var sail_mesh:ImmediateGeometry = $"../Bom/CustomSail"
#export(float) var keel_force: float = 60.0

#onready var sail_trim = hinge_bom.get("angular_limit/upper") setget set_sail_trim

onready var initial_transform:Transform = global_transform

func _ready():
	assert(bom)
	assert(hinge_bom)
	assert(save_manager)
	assert(sail_mesh)
	save_manager.call_deferred("update_data",self)
	set_sail_trim(10.0)
	
	set_front_wave_offset(front_wave_offset)
	set_front_scale(front_scale)
	set_trail_radius(trail_radius)
	set_trail_segment_length(trail_segment_length)
#	set_front_scale_rate(front_scale_rate)
	
#	sail_mesh.regen_mesh = true
#	anim.current_animation = "fold"
#	anim.stop(false)
#	anim.seek(main_haulyard, true)
	#sail_mesh.regen_mesh = true
	anim.play("fold", -1, 2)
	
	
#	assert(mooring_bow_l)
#	assert(mooring_bow_r)

#func _physics_process(delta):
#	update_water_level(delta)
#	update_hit_level(delta)
	#update_moorings(delta)
	
func _process(delta):
	var glob_pos = global_transform.origin
	var forward = -linear_velocity
	var direction = atan2(forward.x, forward.z)
	var horizontal_velocity = Vector2(linear_velocity.x, linear_velocity.z)
	var horizontal_vel_len = horizontal_velocity.length()
	waterMesh.set_trail_position(glob_pos)
	waterMesh.set_trail_direction(direction - (PI/2.0))
	waterMesh.set_trail_speed(horizontal_vel_len * 40.0)
	waterMesh.set_front_direction(global_transform.basis.z)
	bow_particlesL.emitting = (horizontal_vel_len > 1.0)
	bow_particlesL.process_material.initial_velocity = horizontal_vel_len
	bow_particlesR.emitting = (horizontal_vel_len > 1.0)
	bow_particlesR.process_material.initial_velocity = horizontal_vel_len
	
func set_front_wave_offset(val:float):
	front_wave_offset = val
	if waterMesh: waterMesh.set_front_offset(val)
	
func set_front_scale(val:float):
	front_scale = val
	if waterMesh: waterMesh.set_front_scale(val)
	
func set_trail_radius(val:float):
	trail_radius = val
	if waterMesh: waterMesh.set_trail_radius(val)
	
func set_trail_segment_length(val):
	trail_segment_length = val
	if waterMesh: waterMesh.set_trail_segment_length(val)
	
#func set_front_scale_rate(val:float):
#	front_scale_rate = val
#	if waterMesh: waterMesh.set_front_offset_rate(val)

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

#var sail_regen_vals = [0.01, 0.5, 0.99]#[0.01, 0.33, 0.5, 0.7, 0.9, 0.99]
#func check_sail_mesh_regen(prev_val:float, next_val:float):
#	for val in sail_regen_vals:
#		if ((prev_val - val) * (next_val - val)) < 0.0:
#			print("mainhaul prev: ", prev_val, " next: ", next_val)
#			sail_mesh.regen_mesh = true

func heave_mainhaul(delta):
#	if bom.sail_amount < 0.5:
#		$"../AnimationPlayer".play_backwards("fold")
#	var prev_val = main_haulyard
	main_haulyard -= 0.5*delta
	main_haulyard = clamp(main_haulyard, 0, 1)
	
#	check_sail_mesh_regen(prev_val, main_haulyard)
	anim.current_animation = "fold"
	anim.stop(false)
	anim.seek(main_haulyard, true)
	
	return (main_haulyard != 0.0)
	
func ease_mainhaul(delta):
#	if bom.sail_amount > 0.5:
#		$"../AnimationPlayer".play("fold")
#	var prev_val = main_haulyard
	main_haulyard += 0.5*delta
	main_haulyard = clamp(main_haulyard, 0, 1)

#	check_sail_mesh_regen(prev_val, main_haulyard)
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
	$"../AnimationPlayer".play("paddles_reset")
	yield($"../AnimationPlayer","animation_finished")
	$"../AnimationPlayer".play("paddle")
	#apply_torque_impulse(Vector3.DOWN * 10.0)
	
func special_alt():
	$"../AnimationPlayer".play("paddles_reset")
	yield($"../AnimationPlayer","animation_finished")
	$"../AnimationPlayer".play("paddle2")
	
func apply_local_impulse(position:Vector3, impulse):
	var global_pos:Vector3 = global_transform.basis.xform(position)
	var global_imp:Vector3 = global_transform.basis.xform(impulse)
	apply_impulse(global_pos, global_imp)
	
	
func _on_sink():
	print("ON SINK RESPAWN")
	save_manager.load_game()
	
