extends Control

#race task -> simple contidion
#barel gather task -> equipment amount contition
#shooting task -> external amount condition

onready var label = $Label

export(Array,Resource) var tasks

onready var task_active = tasks

#func _ready():
#	assert(task_active)
#	for t in task_active:
#		t.initialize_task(self)
#		t.connect("changed",self,"_on_task_changed")
#	update_label()
#
#func update_label():
#	var new_text:String = "TASKS:\n"
#	var i:int = 1
#	for task in task_active:
#		new_text = new_text + str(i) + ". " + task.get_string_status() + "\n"
#		i=i+1
#	label.text = new_text
#
#func _on_task_changed():
#	print("task changed")
#	update_label()
