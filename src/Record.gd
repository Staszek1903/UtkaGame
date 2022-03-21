extends HBoxContainer

signal selected(item_name)

onready var button = $Button
onready var label = $Label

func _ready():
	assert(button)
	assert(label)
	button.connect("pressed",self,"_button_pressed")
	
func _button_pressed():
	#print("button_pressed, ", button.text)
	emit_signal("selected", button.text)

func set_item_name(name:String):
	button.text = name
	
func set_item_count(val:int):
	label.text = str(val)
