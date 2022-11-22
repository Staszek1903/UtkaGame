extends KinematicBody

onready var audio = $"../AudioStreamPlayer3D"
onready var anim = $"../AnimationPlayer"

onready var bosshpbar = $"/root/BossHp"

var count = 0
var tentacles = []
var eyes = []

func _ready():
	assert(bosshpbar)
	
	for i in 12:
		var ten = get_node("../TentacleProto"+str(i+1))
		#print(i, " ",("../TetancleProto"+str(i+1)), " ", ten)
		tentacles.append( ten )
		
	for i in 4:
		var ten = get_node("../KrakenEye"+str(i+1))
		#print(i, " ",("../TetancleProto"+str(i+1)), " ", ten)
		eyes.append( ten )



func receive_damage(ammount):
	audio.play()
	anim.play("bell")
	count += 1
	if count >= 3: call_the_cthulu()

func call_the_cthulu():
	bosshpbar.visible = true
	bosshpbar.value = 100
	
	for i in eyes:
		i.visible = true
		i.rise()

	var index = [7,1,9,6,0,10,5,3,4,2,8,11]
	for i in index:
		tentacles[i].rise_and_attack()
		yield(get_tree().create_timer(0.5),"timeout")
		
	


#func spawn_tentacle(pos: Vector2):
#	var new_tentacle = tentacle_proto.duplicate()
#	new_tentacle.transform.origin.x = pos.x
#	new_tentacle.transform.origin.z = pos.y
#	new_tentacle.get_node("AnimationPlayer").play("rise")
#	call_deferred("add_child", new_tentacle)
