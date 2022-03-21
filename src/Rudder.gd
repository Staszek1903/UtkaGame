extends Spatial

export(float) var rudder_speed: float = 1
export(float) var max_angle: float = 1
export(float) var rudder_force: float = 30.0
var angle : float = 0.0

onready var init_angle: float = rotation.y
onready var body : RigidBody = get_parent()
onready var force_offset = $ForceOffset.translation
onready var debug = $ForceDebug

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if Input.is_action_pressed("rudder_right") and angle < max_angle:
		angle += rudder_speed * delta
		rotation.y = init_angle +  angle
		
	if Input.is_action_pressed("rudder_left") and angle > -max_angle:
		angle -= rudder_speed * delta	
		rotation.y = init_angle + angle
		
	#var global_vel: Vector3 = body.linear_velocity
	var global_vel: Vector3 =  body.linear_velocity
	#print(global_vel)
	var basis = global_transform.basis
	var local_vel = basis.xform_inv(global_vel)
	var local_vel_h = Vector3(local_vel.x, 0,0)
	var global_impulse = basis.xform(-local_vel_h)
	
	var offset = force_offset + \
	to_global(Vector3()) - body.to_global(Vector3())
	body.add_force(global_impulse * body.mass * delta * rudder_force, offset)
	
	debug.clear()
	debug.draw(global_impulse * delta * 60)
