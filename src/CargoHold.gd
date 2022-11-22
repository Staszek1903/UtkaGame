extends "res://src/MouseArea.gd"

var items:Dictionary = {}
var capacity:Dictionary = {}
const default_capacity = 16

func _ready():
	pass
	
func add_items(items_to_add:Dictionary):
	for i in items_to_add.keys():
		if not i in capacity:
			capacity[i] = default_capacity
		
		if i in items:
			items[i] += items_to_add[i]
		else:
			items[i] = items_to_add[i]
			
		if items[i] > capacity[i]:
			items[i] = capacity[i]
	update_text()
	
func withdraw_items(items_to_withdraw:Dictionary):
	for i in items_to_withdraw.keys():
		if i in items:
			items[i] -= items_to_withdraw[i]
			if items[i] < 0: items.erase(i)
	
	update_text()
	
func get_item_count(item_name:String) -> int:
	if item_name in items:
		return items[item_name]
	return 0
	
func get_capacity(item_name:String) -> int:
	if item_name in capacity:
		return capacity[item_name]
	return default_capacity
			
func update_text():
	var item_text = ""
	for key in items.keys():
		item_text += "%s : %s/%s\n" % [key, items[key], capacity[key]]
		print(">>", item_text, "<<")
	$TextBanner.text = item_text
	$TextBanner.dimentions = Vector2(0.5, items.size()* 0.1)

func _on_CargoHold_mouse_entered():
	update_text()
	$TextBanner.visible = true
	


func _on_CargoHold_mouse_exited():
	$TextBanner.visible = false
