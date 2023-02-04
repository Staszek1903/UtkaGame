extends Node

onready var diary = $"/root/Ui/Diary"

var texts = {
	look= "TUTORIAL: RMB to look around",
	irons= "Right now you stay in irons (upwind),\nits imposible to sail like that. To free yourself press Z", # z forwards
	helm = "Press A/D to move tiller.\nAs you will notice you can steer only when the boat is moving,\nit has no manuverability otherwise.",							# a/d forwards
	ctrl = "To start moving you need to raise sail.\nYou can manage varous things on your boat selecting them by LMB\n Press L_CTRL to highlight interatables and select MainHaulyard",			# ctrl forwards
	heave = "When selected you can ease and heave ropes and other devices using W/S\n Hold S to raise your sail", # raising sail forwards
	heave2 = "Now locate MainSheet and heave it too,\nit should get you moving.",
	hud = "HUD: Two vertical bars on the left are:\nblue one - \"bilge water bar\" - when its full you sink\nyellow red one - \"hunger bar\" - when a red bar will go to zero you die",
	hud2 = "HUD 2: Beneath the bars are some indicators:\nspeed, list, wind angle, compass",
	items = "To make sure you will not starve you need to always have some food in your cargo\nTo vie content of your cargo locate cargo hold on the boat and hover mouse over it\nYou can resuply in food on every island or find it in floating crates and barrels\nTo pick up item in the water just sail over it.",
	docking = "Lastly to dock to island select mooring on your boat and then mooring post on the island.\nThere should be island nearby with a single house\n Try to dock to it and ressuply in food.\nGood luck."
}

var current_tut:int = 0
var tut_done:bool = false

func _input(event):
	if event is InputEventKey and event.pressed \
	and event.scancode == KEY_ENTER:
		advance_tutorial() 

func _ready():
	diary.add_content(texts.look + "\n ENTER to proceed")

func advance_tutorial():
	current_tut += 1
	if current_tut >= texts.size():
		end_tutorial()
		return
	#var current_key = texts.keys()[current_tut]
	diary.add_content(texts.values()[current_tut] + "\n ENTER to proceed")
	
func end_tutorial():
	diary.add_content("TUTORIAL_DONE")
	queue_free()
