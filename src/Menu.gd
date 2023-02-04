extends Spatial

func _ready():
	$"/root/Ui".visible = false

func _on_StartButton_pressed():
	$Label.visible = true
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	$"/root/Ui".visible = true
	get_tree().change_scene("res://scenes/OceanLevel.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()

