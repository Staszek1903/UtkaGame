extends RigidBody

#func _ready():
#	add_to_group("mockup")

func _physics_process(delta):
	#GRAVITY
	var gravity_force = Vector3(0,-9.8,0)
	add_central_force(gravity_force * mass)
	
	#VERTICAL DUMP
	var vel_vert = Vector3(
			0, linear_velocity.y, 0)
	add_central_force(-vel_vert * mass * 2)
