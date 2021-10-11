extends Control

onready var label = $Label
var raw_text = "Engine: %s\n%s\n%s"
var state = "OFF"
var gear = "N"
var power = "0"

func _ready():
	update_text()

func set_state(s:String):
	state = s
	update_text()
	
func set_gear(s:String):
	gear = s
	update_text()
	
func set_power(s:String):
	power = s
	update_text()
	
func update_text():
	label.set_text(raw_text % [state,gear,power])
