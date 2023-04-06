extends BasicBoat

onready var rudder = $Rudder
export(bool) var sails_active = false setget set_sails_active

	
func set_sails_active(val:bool):
	sails_active = val
	if bom:
		bom.is_sail_up = val
		bom.sail_amount = 1.0
	if jib:
		jib.is_sail_up = val
		jib.sail_amount = 1.0

func get_velocity_heading():
	var vel_direction:Vector3 = linear_velocity
	vel_direction.y = 0
	vel_direction = vel_direction.normalized()
	var vel_basis:Basis = Basis(Vector3.UP.cross(-vel_direction), Vector3.UP, -vel_direction)
	vel_basis = vel_basis.orthonormalized()
	return vel_basis.get_euler().y
	
func set_sail_trim(_val: float):
	pass
#	val = clamp(val, 0.0, 90.0)
#	sail_trim = val
#	hinge_bom.set("angular_limit/upper", val)
#	hinge_bom.set("angular_limit/lower", -val)
#	hinge_jib.set("angular_limit/upper", val)
#	hinge_jib.set("angular_limit/lower", -val)

onready var floaters:Array = [ $FloaterBow, $FloaterStern,
	$FloaterPort, $FloaterStar ]

func set_floaters_height(h:float):
	for f in floaters:
		f.depthBeforeSubmerged = h
		
func set_floaters_enabled(en:bool):
	for f in floaters:
		f.enabled = en
		
func _on_sink():
	var spawn = $ItemSpawn
	spawn.spawn_all()
	spawn.free_items()
