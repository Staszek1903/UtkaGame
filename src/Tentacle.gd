extends Spatial

onready var anim = $AnimationPlayer

func rise_and_attack():
	anim.play("rise")
	yield(anim,"animation_finished")
	anim.play("attack")
	yield(anim,"animation_finished")
	anim.play_backwards("rise")
	

	
