extends Control

onready var button_proto = $VBoxContainer/BuildingListButton
onready var container = $VBoxContainer
var buttons = []

var building = null

func building_available(node:Node):
	building = node
	if node:
		show()
		update_buttons()
	else: hide()
	
func update_front():
	update_buttons()
	
func update_buttons():
	if not building: return
	var dict = building.required_items
	var size = dict.size()
	while buttons.size() < size:
		var new_button = button_proto.duplicate()
		container.add_child(new_button)
		buttons.append(new_button)
	for b in buttons: b.visible = false
	
	var i:int = 0
	for key in dict:
		buttons[i].item_name = key
		buttons[i].item_count = dict[key]
		buttons[i].visible = true
		i+=1

func show():
	$AnimationPlayer.play_backwards("out")

func hide():
	$AnimationPlayer.play("out")

func _on_BuildingListButton_item_pressed(item_name):
	if building: building.item_pressed(item_name)
