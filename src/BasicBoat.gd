extends RigidBody
class_name BasicBoat

onready var hunger_bar = $"/root/Ui/HungerLevel"
onready var player_control = $"../PlayerControl"

onready var bom = $"../Bom"
onready var jib = $"../fok_sheet"

onready var keelForceOffset = $KeelForceOffset
onready var hinge_bom: HingeJoint = $"../LowerSailHinge"
onready var hinge_jib: HingeJoint = $"../FokHinge"

onready var sail_trim = hinge_bom.get("angular_limit/upper") setget set_sail_trim

export(float) var keel_force: float = 60.0

const hunger_time:float = 240.0
var hunger:float = 0

var vip_slot:Spatial = null

func _ready():
	assert(bom)
	assert(hunger_bar)
	assert(player_control)
	add_to_group("boat")
	call_deferred("subscribe_to_indicators")

func set_current():
	call_deferred("subscribe_to_indicators")
	$CameraPivot.set_current()
	$"../PlayerControl".current = true
	
func unset_current():
	$"../PlayerControl".current = false

func subscribe_to_indicators():
	$"/root/Ui/Indicators".set_boat(self)

func _physics_process(delta):
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
	if player_control.current:
		update_hunger(delta)

func set_sail_trim(val: float):
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
