extends StaticBody

signal start_race

func start_dialog(dialog:String):
	var dialogic = Dialogic.start(dialog)
	add_child(dialogic)
	dialogic.connect("timeline_end", self, "dialog_end")
	dialogic.connect("dialogic_signal", self, "dialogic_signal")
	
func dialog_end(dummy):
	pass

func _on_Quai_action():
	start_dialog("Race")

func dialogic_signal(val:String):
	if val == "start_race":
		emit_signal("start_race")
