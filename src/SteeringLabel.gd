extends Control

onready var label = $Label

var format_text = "Steering %s:\n%s"# %.1f%%"
var interface_name:String = "test" setget set_interface_name
var info:String setget set_info

func _ready():
	update_label()
	set_steered_interface(0)

func set_interface_name(val:String):
	interface_name = val
	update_label()
	
func set_info(val:String):
	info = val
	update_label()
	
func update_label():
	label.text = (format_text %[interface_name, info])
	
func set_steered_interface(index:int):
	var down = 130
	var up = 110
	
#	for i in 4:
#		get_node("TextureRect"+str(index+1)).rect_position.y = \
#			up if index == i else down
			
	
	$TextureRect1.rect_position.y = up if index == 0 else down
	$TextureRect2.rect_position.y = up if index == 1 else down
	$TextureRect3.rect_position.y = up if index == 2 else down
	$TextureRect4.rect_position.y = up if index == 3 else down
