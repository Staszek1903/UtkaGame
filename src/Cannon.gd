extends Spatial

export(float) var recoil_time:float = 2.0
export(float) var ball_velocity = 100.0
var timer: float = 0
onready var ball_proto:Spatial = $CanonBall
onready var aim_cone:Spatial = $CanonBarrel/AimCone
onready var boat = get_parent().get_parent()


func _ready():
	if not ball_proto: ball_proto = $CannonBall
	ball_proto.get_parent().remove_child(ball_proto)
	#print("cannon boat ", ball_proto.self_boat, " ", boat.name)

func _process(delta):
	if timer > 0.0:
		timer -= delta
		
#func _input(event):
##	print("EVE")
##	if not is_tool : return
#	if event is InputEventKey and event.pressed and event.scancode == KEY_SPACE:
#		shoot()
		
func set_pitch(pitch:float):
	$CanonBarrel.rotation.x = clamp(pitch, 0.0 , 1.0)
	
func is_ready_to_fire() -> bool:
	return (timer <= 0.0)

func fire() -> bool:
	if timer > 0.0: return false
	if not ball_proto: ball_proto = $CannonBall
	var new_ball = ball_proto.duplicate()
	get_tree().get_root().add_child(new_ball)
	new_ball.global_transform = $CanonBarrel/ShootPos.global_transform
	new_ball.decay(10)
	new_ball.self_boat = boat
	timer = recoil_time
	var shooting_normal = -$CanonBarrel.global_transform.basis.z.normalized()
	new_ball.linear_velocity =  shooting_normal * ball_velocity
	#print(new_ball.linear_velocity.length())
	$CanonBarrel/Particles.emitting = true
	$AudioStreamPlayer3D.play()
	return true
	
func get_max_range()->float:
	return get_range(deg2rad(45))
	
export(float) var range_qoute = 3.0
func get_range(angle:float) -> float:
	var a = 9.8
	var vx = ball_velocity * cos(angle)
	var vy = ball_velocity * sin(angle)
	var result = vx*((vy+sqrt(vy*vy+2.0*a))/a)
	return result*range_qoute
