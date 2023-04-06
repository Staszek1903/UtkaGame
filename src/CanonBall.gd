extends RigidBody

var self_boat:Spatial = null
onready var waterManager = $"/root/Root/WaterManager"
onready var particle_splash = $ParticlesSplash

var mark_for_free:bool = false

func _physics_process(_delta):
	var global_pos = global_transform.origin
	add_central_force(Vector3.DOWN * mass * 9.8)
	var wave = waterManager.wave(Vector2(global_pos.x, global_pos.z))
	
	if mark_for_free:
		if not particle_splash.emitting:
			print("CANNON BALL SPLASH FREE")
			queue_free()
	elif wave > global_pos.y:
		particle_splash.global_transform.basis = Basis()
		particle_splash.emitting = true
		$AudioSplash.play()
		#print("SLASH")
		mark_for_free = true
	
	

func decay(_seconds):
	#print("TO BE FREED")
	yield(get_tree().create_timer(10), "timeout")
	queue_free()
	#print("FREEING BALL")


func _on_DamageTrigger_body_entered(body):
	#print("DAMAGE TRIGGE: ", body, " ", body.name, " self: ", self_boat)
	if body == self_boat:
		print("SELF DAMAGE")
		return
	
	if body.has_method("receive_damage"):
		#print("damage dealt")
		body.receive_damage(1)
		$Particles.emitting = true
		$AudioBoom.play()
	
	#var velocity:Vector3 = Vector3.ZERO
#	var has_vel = ("linear_velocity" in body)
#	print("damage linear_velocity: ", has_vel)
#	if(has_vel):
#		velocity += body.linear_velocity
#
#	print("other vel: ", body.linear_velocity)
#	print("vel:", linear_velocity)
