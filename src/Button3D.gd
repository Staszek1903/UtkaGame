tool
extends "res://src/MouseArea.gd"

export(String) var text = "SAMPLE TEXT" setget set_text

func set_text(val:String):
	text = val
	call_deferred("set_text_deferred", val)
	
func set_text_deferred(val:String):
	$Text3D.text = val
