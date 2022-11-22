extends Control

signal emptied

onready var bar = $ProgressBar
var value:float setget set_value

func set_value(val:float):
	if value > 0:
		visible = true
	value = val
	bar.value = val

func take_hp(val:float):
	value -= val
	bar.value = value
	if bar.value <= 0:
		get_tree().call_group("krakenmouth", "rise_and_attack")
		print("BOSS DEFECATE")
		visible = false
		emit_signal("emptied")
