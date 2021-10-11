extends RigidBody

onready var floater = $FloaterBow
onready var floater2 = $FloaterStern
onready var floater3 = $FloaterPort
onready var keelForceOffset = $KeelForceOffset
onready var debug = $ForceDebug
onready var hinge1: HingeJoint = $"../UpperSailHinge"
onready var hinge2: HingeJoint = $"../LowerSailHinge"

export(float) var keel_force: float = 60.0

onready var topenanta = hinge1.get("angular_limit/upper") setget set_topenanta

func _ready():
	pass # Replace with function body.

func set_topenanta(val: float):
	val = clamp(val, 0, 90)
	topenanta = val
	hinge1.set("angular_limit/upper", val)
	hinge2.set("angular_limit/upper", val)
	hinge1.set("angular_limit/lower", -val)
	hinge2.set("angular_limit/lower", -val)

func _physics_process(delta):
	var global_pos = to_global(Vector3())
	if Input.is_action_pressed("ease_mainsheet"):
		set_topenanta(topenanta + 10 * delta)
	if Input.is_action_pressed("heave_mainsheet"):
		set_topenanta(topenanta - 10 * delta)
	#print(hinge1.get("angular_limit/lower"))
	if Input.is_action_pressed("motor_fwd"):
		var floater_pos = floater.to_global(Vector3())
		add_central_force(floater_pos - global_pos)
	if Input.is_action_pressed("ui_right"):
		var pos = floater2.to_global(Vector3()) - global_pos
		var force = floater3.to_global(Vector3()) - global_pos
		add_force(force,pos)
		#add_central_force(force)
	if Input.is_action_pressed("ui_left"):
		var pos = floater2.to_global(Vector3()) - global_pos
		var force = floater3.to_global(Vector3()) - global_pos
		add_force(-force,pos)
		#add_central_force(force)
	
	#VERTICAL DUMP
	var vel_vert = Vector3(
			0, linear_velocity.y, 0)
	add_central_force(-vel_vert *2)
	
	#KEEL
	var keel_pos = keelForceOffset.to_global(Vector3())
	var global_vel = linear_velocity
	var local_vel = global_transform.basis.xform_inv(global_vel)
	var local_vel_h  = Vector3(local_vel.x, 0,0)
	var global_vel_h = global_transform.basis.xform(local_vel_h)
	add_force(-global_vel_h*delta * keel_force, keel_pos - global_pos)
	
	#GRAVITY
	var gravity_force = Vector3(0,-9.8,0)
	add_central_force(gravity_force * mass)
	
	debug.clear()
	debug.draw(vel_vert)
	debug.draw(global_vel_h)
	
func get_mooring_end(area) -> Spatial:
	if area == $SternArea:
		return $MooringEndStern as Spatial
	elif area == $BowArea:
		return $MooringEndBow as Spatial
	return null
	
func get_mooring_rope(area) -> Spatial:
	if area == $SternArea:
		return $"../SternPortMooring" as Spatial
	elif area == $BowArea:
		return $"../BowMooring" as Spatial
	return null
