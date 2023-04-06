extends Spatial

export(float) var max_angle: float = 1
export(float) var rudder_force: float = 30.0
var rudder_speed = 10.0
var angle : float = 0.0 setget set_angle

onready var init_angle: float = rotation.y
onready var body : RigidBody = get_parent()
onready var force_offset = $ForceOffset.translation
onready var debug = $ForceDebug
onready var mesh = $RudderMesh

func change_angle(diff:float):
	set_angle(angle+diff)
	
func set_angle(val:float):
	angle = clamp(val, -max_angle, max_angle)
	#rotation.y = init_angle +  angle
	
func set_angle_normalized(val:float):
	val *= max_angle
	set_angle(val)
	
func _physics_process(delta):
	if mesh:
		mesh.rotation.y \
			= mesh.rotation.y \
			+ (angle - mesh.rotation.y) * delta * rudder_speed
	else:
		rotation.y = rotation.y \
		+ (angle - rotation.y) * delta * rudder_speed
#	if Input.is_action_pressed("rudder_right") and angle < max_angle:
#		angle += rudder_speed * delta
#		rotation.y = init_angle +  angle
#
#	if Input.is_action_pressed("rudder_left") and angle > -max_angle:
#		angle -= rudder_speed * delta	
#		rotation.y = init_angle + angle
		

	var global_vel: Vector3 =  body.linear_velocity

	var basis = Basis()
	if mesh:
		basis = mesh.global_transform.basis
	else:
		basis = global_transform.basis

	var local_vel = basis.xform_inv(global_vel)
	var local_vel_h = Vector3(local_vel.x, 0,0)
	var global_impulse = basis.xform(-local_vel_h)
	
	var offset = Vector3()
	if mesh:
		offset = force_offset + \
		mesh.to_global(Vector3()) - body.to_global(Vector3())
	else:
		offset = force_offset + \
		to_global(Vector3()) - body.to_global(Vector3())
	
	body.add_force(global_impulse * body.mass * delta * rudder_force, offset)
	debug.clear()
	debug.draw(global_impulse * delta * 60)
