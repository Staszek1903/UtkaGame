extends Control

onready var bar = $ProgressBar
onready var hitbars = [ $HitBar1, $HitBar2, $HitBar3 ]
onready var hit_label = $HitBar1/Label

var value setget set_value
var hit_level setget set_hit_level

func set_value(val:float):
	value = val
	bar.value = val

func set_hit_level(val:float):
	hit_level = val
	hitbars[0].visible = (val > 0.0)
	var red = val - int(val - 0.001)
	hitbars[0].value = red
	hit_label.text = str(ceil(val))
#	for i in 3:
#		hitbars[i].visible = (val>i)
#		hitbars[i].value = val
	
