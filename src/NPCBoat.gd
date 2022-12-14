extends BasicBoat

onready var rudder = $Rudder
export(bool) var sails_active = false setget set_sails_active

	
func set_sails_active(val:bool):
	sails_active = val
	bom.is_sail_up = val
	bom.sail_amount = 1.0
	jib.is_sail_up = val
	jib.sail_amount = 1.0

func get_velocity_heading():
	var vel_direction:Vector3 = linear_velocity
	vel_direction.y = 0
	vel_direction = vel_direction.normalized()
	var vel_basis:Basis = Basis(Vector3.UP.cross(-vel_direction), Vector3.UP, -vel_direction)
	vel_basis = vel_basis.orthonormalized()
	return vel_basis.get_euler().y
	
func set_sail_trim(val: float):
	val = clamp(val, 0.0, 90.0)
	sail_trim = val
	hinge_bom.set("angular_limit/upper", val)
	hinge_bom.set("angular_limit/lower", -val)
	hinge_jib.set("angular_limit/upper", val)
	hinge_jib.set("angular_limit/lower", -val)

func set_floaters_height(val:float):
	pass

func set_floaters_enabled(en:bool):
	pass
