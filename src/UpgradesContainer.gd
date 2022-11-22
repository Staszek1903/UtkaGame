extends VBoxContainer

onready var button_proto = $BuildingListButton
onready var container = self
var buttons = []

var upgrades = null

func update_buttons():
	if not upgrades: return
	var dict = upgrades.required_items.properties_db
	var size = dict.size()
	while buttons.size() < size:
		var new_button = button_proto.duplicate()
		container.add_child(new_button)
		buttons.append(new_button)
	for b in buttons: b.visible = false
	
	var i:int = 0
	for key in dict:
		var value = dict[key]
		buttons[i].item_name = ItemsEnum.Items.keys()[key]
		buttons[i].item_count = value["quantity"]
		buttons[i].visible = true
		i+=1
