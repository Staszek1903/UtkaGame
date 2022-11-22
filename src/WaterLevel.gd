extends Control

onready var bar = $ProgressBar
onready var hitbars = [ $HitBar1, $HitBar2, $HitBar3 ]

func _on_Boat_water_level_changed(val):
	bar.value = val

func _on_Boat_hit_level_changed(val):
	for i in 3:
		hitbars[i].visible = (val>i)
		hitbars[i].value = val
	
