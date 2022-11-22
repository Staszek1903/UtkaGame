extends KinematicBody

func _ready():
	collision_layer = 0
	collision_mask = 0

func rise():
	visible = true
	$AnimationPlayer.play("rise")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("idle")
	collision_layer = 1
	collision_mask = 1
	
var receive_damage = 0

func receive_damage(val):
	if not visible: return
	$"/root/BossHp".take_hp(25)
	$AnimationPlayer.play_backwards("rise")
	yield($AnimationPlayer, "animation_finished")
	visible = false
	collision_layer = 0
	collision_mask = 0
	#queue_free()

