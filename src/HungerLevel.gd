extends Control

onready var hunger = $HungerBar
onready var starvation = $StarvationBar

func set_hunger_level(val:float):
	hunger.value = val
	
func set_starvation_level(val:float):
	starvation.value = val
