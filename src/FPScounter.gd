extends Control

onready var label = $Label

func _process(_delta):
	label.text = str(Engine.get_frames_per_second())
