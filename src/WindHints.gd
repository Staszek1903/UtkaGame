extends Sprite

func _ready():
	$"/root/WindHints".visible = false

func _on_Area2D_mouse_entered():
	$"/root/WindHints".visible = true

func _on_Area2D_mouse_exited():
	$"/root/WindHints".visible = false
