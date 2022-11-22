extends StaticBody

signal repair_bridge

#onready var inventory = $"/root/Inventory"
var have_bridge_part = false

#func _ready():
#	assert(inventory)

func start_dialog(dialog:String):
	Dialogic.set_variable("BridgeRepaired", have_bridge_part)
	var dialogic = Dialogic.start(dialog)
	add_child(dialogic)
	dialogic.connect("timeline_end", self, "dialog_end")
	
	#get_tree().paused = true
	
func dialog_end(dummy):
	print("DIALOG END")
	#get_tree().paused = false


func _on_Quai_action():
	pass
#	if inventory.get_quantity("CogWheel") > 0:
#		have_bridge_part = true
#		emit_signal("repair_bridge")
#	start_dialog("Bridge")
