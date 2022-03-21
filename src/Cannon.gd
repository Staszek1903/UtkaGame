extends Spatial

export(float) var recoil_time:float = 2.0
export(float) var ball_velocity = 200.0
var timer: float = 0
onready var ball_proto:Spatial = $CanonBall


func _ready():
	$CanonBall.get_parent().remove_child($CanonBall)

func _process(delta):
	if timer > 0.0:
		timer -= delta
		
func set_pitch(pitch:float):
	$CanonBarrel.rotation.x = pitch
	
func is_ready_to_fire() -> bool:
	return (timer <= 0.0)

func shoot():
	if timer > 0.0: return
	var new_ball = ball_proto.duplicate()
	get_tree().get_root().add_child(new_ball)
	new_ball.global_transform = $CanonBarrel/ShootPos.global_transform
	new_ball.decay(10)
	timer = recoil_time
	new_ball.linear_velocity = -$CanonBarrel.global_transform.basis.z * \
								ball_velocity
	#print(new_ball.linear_velocity.length())
	$CanonBarrel/Particles.emitting = true
	
func get_max_range()->float:
	return get_range(deg2rad(45))
	
func get_range(angle:float) -> float:
	var a = 9.8
	var vx = ball_velocity * cos(angle)
	var vy = ball_velocity * sin(angle)
	var result = vx*((vy+sqrt(vy*vy+2.0*a))/a)
	return result
