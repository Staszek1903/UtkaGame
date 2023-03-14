extends Spatial

func _ready():
	$"/root/Ui".visible = false
	$"MouseInverted".pressed = true
	
	var file = File.new()
	if file.file_exists("user://savegame.save"):
		$ContinueBody.mode = RigidBody.MODE_RIGID
		
	#VISUAL:
	$Candle/AnimationPlayer.seek(0.2,true)

func _on_StartButton_pressed():
	$Label.visible = true
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	$"/root/Ui".visible = true
	
	var root = get_tree().get_root()
	root.remove_child(self)
	queue_free()
	var ocean_scene = load("res://scenes/OceanLevel.tscn")
	root.add_child(ocean_scene.instance())

func _on_ContinueButton_pressed():
	$Label.visible = true
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	$"/root/Ui".visible = true
	$"/root/Ui/CheatConsole".load_on_new_scene = true
	get_tree().change_scene("res://scenes/OceanLevel.tscn")
	

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_Fullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed

func _on_MouseInverted_toggled(button_pressed):
	$"/root/Ui/CheatConsole".mouse_y_inverted = button_pressed
