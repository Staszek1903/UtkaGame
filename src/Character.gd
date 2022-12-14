extends Spatial

onready var anim = $AnimationPlayer

func play_anim(name:String):
	anim.play(name)
