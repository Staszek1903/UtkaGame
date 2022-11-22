extends Spatial

onready var anim = $AnimationPlayer

func _ready():
	add_to_group("krakenmouth")

func rise_and_attack():
	anim.play("rise")
	yield(anim,"animation_finished")
	anim.play("close")
	yield(anim,"animation_finished")
	var boat = get_parent()
	boat.floater.enabled = false
	boat.floater2.enabled = false
	boat.floater3.enabled = false
	boat.floater4.enabled = false
	boat.end_game()
	
	yield(get_tree().create_timer(3),"timeout")
	
	get_tree().call_group("catchable", "remove_catchable")
	get_tree().change_scene("res://scenes/AfterLife.tscn")
	boat.queue_free()
	boat.queue_free()

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_K:
		rise_and_attack()
