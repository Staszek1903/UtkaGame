extends Button

signal item_pressed(item_name)

var item_name:String setget set_item_name
var item_count:int setget set_item_count

func set_item_name(val:String):
	item_name = val
	update_text()
	
func set_item_count(val:int):
	item_count =val
	update_text()

func update_text():
	text = "%s x%d" % [item_name, item_count]

func _on_BuildingListButton_pressed():
	emit_signal("item_pressed", item_name)
	
