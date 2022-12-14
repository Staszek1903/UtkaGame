extends Control

onready var bar = $ProgressBar
onready var hitbars = [ $HitBar1, $HitBar2, $HitBar3 ]

var value setget set_value
var hit_level setget set_hit_level

func set_value(val:float):
	value = val
	bar.value = val

func set_hit_level(val:float):
	for i in 3:
		hitbars[i].visible = (val>i)
		hitbars[i].value = val
	
