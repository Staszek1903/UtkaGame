tool
extends "res://src/MouseArea.gd"

export(String) var text = "SAMPLE TEXT" setget set_text

func set_text(val:String):
	text = val
	$Text3D.text = val
