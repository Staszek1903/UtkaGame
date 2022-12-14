extends BasicBoat

onready var floater = $FloaterBow
onready var floater2 = $FloaterStern
onready var floater3 = $FloaterPort
onready var floater4 = $FloaterStar
onready var jib = $"../fok_sheet"

onready var debug = $ForceDebug
onready var rudder = $Rudder
#onready var hinge_bom: HingeJoint = $"../LowerSailHinge"
#onready var hinge_jib: HingeJoint = $"../FokHinge"
#onready var bom = $"../Bom"
onready var main_anim = $"../MainSailPlayer"
onready var jib_anim = $"../FokAnimPlayer"
onready var bow_mooring = $"../BowMooring"
#onready var inventory = $"/root/Inventory"

onready var engine = $Engine

#export(float) var keel_force: float = 60.0

#onready var sail_trim = hinge_bom.get("angular_limit/upper") setget set_sail_trim

onready var initial_transform:Transform = global_transform


func _ready():
	assert(bow_mooring)
	assert(hinge_bom)
	assert(main_anim)
	assert(jib_anim)
	#assert(inventory)
	assert(engine)
	assert(jib)

func _physics_process(delta):
	update_cannon()
	update_water_level(delta)
	update_hit_level(delta)
	
	if docked: heave_mooring(delta)
	
func shoot():
	$Cannon.shoot()

#####################
# MOORING			#
#####################

var docking_point:Spatial = null
var docked:float = false

func _on_CrosshairArea_area_entered(area):
	#print(area," ", area.name," ENTERED")
	if area.name == "DockPointArea" and not docked:
		print("A")
		docking_point = area.get_parent()
		docking_point.indicator_visible = true

func _on_CrosshairArea_area_exited(area):
	#print(area," ", area.name," EXITED")
	if area.get_parent() == docking_point and not docked:
		docking_point.indicator_visible = false
		docking_point = null

func throw_mooring():
	if not docked and docking_point:
		docking_point.docked_rope_end = $MooringEndBow
		docking_point.indicator_visible = false
		docked = true
		bow_mooring.set_length(0)
	
func retrieve_mooring():
	if docked:
		docking_point.docked_rope_end = null
		docking_point.indicator_visible = false
		docked = false
		$MooringEndBow.global_transform = $MooringEndBowConst.global_transform
		bow_mooring.set_length(0)
		
func heave_mooring(delta):
	bow_mooring.apply_force(300 * delta)

#################################
# CATCHING ITEMS				#
#################################

var catchable_bodies = []
var items_to_be_caught = []
func _on_ItemCatchArea_body_entered(body):
	if body.get("item") != null:
		catchable_bodies.append(body)
		print("added catch item", body)

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
		print("\t", i.item)
		#i.queue_free()
		$CargoSlots.add_item(i)
		#inventory.add_item(i.item, 1)
		#$"/root/InventoryList".update_front()
	items_to_be_caught = []
	

func let_items_go():
	$ItemTween.remove_all()
	items_to_be_caught = []
	
func throw_cargo():
	var node:RigidBody = $CargoSlots.remove_item()
	print("throwing: ", node)
	if not node: return
	get_tree().get_root().add_child(node)
	node.global_transform = $CargoDrop.global_transform
	node.linear_velocity = Vector3.ZERO
	#node.apply_central_impulse(Vector3.UP * 100)

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
	ind.transform.origin.z = -dist


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
	get_tree().call_group("spawn_point", "respawn")

	
var end_game:bool = false
func end_game():
	end_game = true

func set_water_level(val):
	if end_game: return
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

func receive_damage(_dmg:int = 1):
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

func set_sail_trim(val: float):
	val = clamp(val, 0.0, 90.0)
	sail_trim = val
	hinge_bom.set("angular_limit/upper", val)
	hinge_bom.set("angular_limit/lower", -val)
	hinge_jib.set("angular_limit/upper", val)
	hinge_jib.set("angular_limit/lower", -val)
