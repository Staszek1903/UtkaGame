extends TaskResource
class_name InventoryTask

export(String) var required_item_name:String = ""
export(int) var required_item_count:int = 0
var current_item_count:int = 0

func initialize_task(task_man:Node):
	var node = task_man.get_node(node_path)
	node.connect("inventory_changed",self, "_on_inventory_changed")

func get_string_status():
	return msg + "(" + str(current_item_count)+"/"+str(required_item_count)+")"\
		+ (" DONE" if done else "")

func _on_inventory_changed(inv):
	current_item_count = inv.inventory[required_item_name]
	done = (current_item_count >= required_item_count)
	emit_signal("changed") 
