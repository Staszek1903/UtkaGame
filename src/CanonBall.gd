extends RigidBody

func _physics_process(delta):
	add_central_force(Vector3.DOWN * mass * 9.8)

func decay(seconds):
	#print("TO BE FREED")
	yield(get_tree().create_timer(10), "timeout")
	queue_free()
	#print("FREEING BALL")


func _on_DamageTrigger_body_entered(body):
	print("DAMAGE TRIGGE: ", body.name)
	if body.has_method("receive_damage"):
		print("damage dealt")
		body.receive_damage(1)
	
	#var velocity:Vector3 = Vector3.ZERO
#	var has_vel = ("linear_velocity" in body)
#	print("damage linear_velocity: ", has_vel)
#	if(has_vel):
#		velocity += body.linear_velocity
#
#	print("other vel: ", body.linear_velocity)
#	print("vel:", linear_velocity)
