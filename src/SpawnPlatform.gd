extends Spatial

export(int) var spawn_id = 0

var is_last_spawn = false
var spawn_ready:bool = true
var boat = null

func _ready():
	add_to_group("spawn_point")

func _input(event):
	if event is InputEventKey and event.pressed and spawn_ready:
		#print("code: ", event.scancode, KEY_0, spawn_id)
		if (event.scancode == (KEY_0 + spawn_id)):
			respawning_procedure()
			
func respawning_procedure():
	$Camera.current = true
	is_last_spawn = true
	get_tree().call_group("spawn_point", "despawn_boat")
	call_deferred("spawn_sloop")
	var pos = Vector2(global_transform.origin.x,
				 global_transform.origin.z)
	get_tree().call_group("watertile", "group_reposition", pos)

#func spawn_boat():
#	var boat_scene:PackedScene = load("res://scenes/Utka.tscn")
#	boat = boat_scene.instance()
#
#	#	get_tree().get_root().add_child(boat)
#	add_child(boat)
#	boat.global_transform = $boat.global_transform
	
func spawn_sloop():
	var boat_scene:PackedScene = load("res://scenes/boats/SloopBoat.tscn")
	boat = boat_scene.instance()
	
	#	get_tree().get_root().add_child(boat)
	add_child(boat)
	boat.global_transform = $boat.global_transform

func despawn_boat():
	if boat:
		boat.queue_free()
		boat = null

func _on_Boat_Detect_body_entered(body):
	if body.name !=  "Boat": return
	spawn_ready = false
	yield(get_tree().create_timer(0.5), "timeout")
		
	$AnimationPlayer.play("go",-1, 0.5)
	if boat:
		boat.get_node("Boat/CameraPivot/Camera").current = true
	
	yield($AnimationPlayer,"animation_finished")
	yield(get_tree().create_timer(3), "timeout")
	$AnimationPlayer.play("go",-1,-2,true)
	yield($AnimationPlayer,"animation_finished")
	spawn_ready = true
	#$AnimationPlayer.play("go")

func respawn():
	if is_last_spawn:
		respawning_procedure()
