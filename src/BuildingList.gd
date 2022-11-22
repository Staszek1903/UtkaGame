extends Control

onready var button_proto = $VBoxContainer/BuildingListButton
onready var container = $VBoxContainer
var buttons = []

var building = null

func _ready():
	call_deferred("move_to_last_position")

func move_to_last_position():
	#move to last position in chierarchy
	var parent = get_parent()
	var child_count = parent.get_child_count()
	parent.move_child(self, child_count-1)

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
	var dict = building.required_items.properties_db
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

func show():
	$AnimationPlayer.play_backwards("out")

func hide():
	$AnimationPlayer.play("out")

func _on_BuildingListButton_item_pressed(item_name):
	if building: building.item_pressed(item_name)
