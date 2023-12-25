extends "res://src/MouseArea.gd"

onready var uimessages = $"/root/Ui/UIMessages"

var items:Dictionary = {}
export(Dictionary) var capacity:Dictionary = {}
export(int) var default_capacity = 64

func _ready():
	for key in ["Food", "Fabric", "Wood", "Steel", "Cannonball"]:
		if not has_node(key): continue
		var node = get_node(key)
		for child in node.get_children():
			child.visible = false
		
		if not key in capacity:
			capacity[key] = default_capacity
	
func add_items(items_to_add:Dictionary) -> bool:
	for i in items_to_add.keys():
		if not i in capacity:
			return false
#			capacity[i] = default_capacity
		
		var before:int = 0
		
		if i in items:
			before = items[i]
			items[i] += items_to_add[i]
		else:
			items[i] = items_to_add[i]
			
		if items[i] > capacity[i]:
			items[i] = capacity[i]
			
		var after = items[i]
		
		uimessages.display(
				i+ " +" \
				+ str(after-before) \
#				+ " ("+ str(hold.get_item_count(iname)) +")"
				)

	update_text()
	return true
	
	
	
func withdraw_items(items_to_withdraw:Dictionary):
	for i in items_to_withdraw.keys():
		if i in items:
			items[i] -= items_to_withdraw[i]
			if items[i] < 0: var _b = items.erase(i)
	
			uimessages.display(
						i+ " -" \
						+ str(items_to_withdraw[i]), Color.gray)
	
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
		if items[key] > 0:
			item_text += "%s : %s/%s\n" % [key, items[key], capacity[key]]
		#print(">>", item_text, "<<")
	if items.size() == 0:
		item_text = "Cargo empty"

	$TextBanner.text = item_text
	$TextBanner.dimentions = Vector2(0.5, max(1,items.size()) * 0.1)
	
	update_mesh()
	
func update_mesh():
	for key in items.keys():
		if not has_node(key): continue
		var node = get_node(key)
		var content:int = items[key]
	
		var cur_index:int = 0
		for child in node.get_children():
			child.visible = (cur_index < content)
			cur_index += 1

func _on_CargoHold_mouse_entered():
	update_text()
	$TextBanner.visible = true
	


func _on_CargoHold_mouse_exited():
	$TextBanner.visible = false
