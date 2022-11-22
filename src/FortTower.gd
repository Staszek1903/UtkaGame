extends RigidBody

onready var cannon = $Cannon
onready var tween = $Tween
onready var max_range = cannon.get_max_range()
var target_body = null


func _ready():
	cannon.set_pitch(deg2rad(45))

func _process(delta):
	if not cannon: return
	if not target_body: return
	if not cannon.is_ready_to_fire(): return
	var trg_pos = target_body.global_transform.origin
	var trg_vect = trg_pos - global_transform.origin
	var trg_dist = trg_vect.length()
	
	if trg_dist > max_range : return
	
	trg_vect *= -1
	var angle = atan2(trg_vect.x, trg_vect.z)
	
	#var q = (trg_dist-10)/max_range
	var q = (trg_dist*9.8)/pow(cannon.ball_velocity,2)
	var pitch = asin(q) / 2.0

	#print("DISTANCE: ", trg_dist, " max_range: ", max_range," q: ", q, " pitch: ", pitch)
	cannon.rotation.y = angle
	cannon.set_pitch(pitch)
	cannon.shoot()

func receive_damage(dmg:int = 1):
	if cannon : cannon.queue_free()
	cannon = null
	var t = $CSGCombiner.transform
	var t2 = t
	t2.origin -= Vector3(0,10,0)
	tween.interpolate_property($CSGCombiner, "transform", t, t2, 2)
	tween.start()
#	yield(tween,"tween_all_completed")
#	queue_free()


func _on_AgrArea_body_entered(body):
	if body.name == "Boat": target_body = body


func _on_AgrArea_body_exited(body):
	if body == target_body: target_body = null
