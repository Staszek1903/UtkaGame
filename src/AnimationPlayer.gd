extends AnimationPlayer


func play_animation(anim:String):
	if not is_playing():
		play(anim)
