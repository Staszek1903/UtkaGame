extends VBoxContainer

signal item_selected

onready var record_proto:HBoxContainer = $Record

var item_list = {}
var record_list = {}
var selected_item:String = "Barel"

func set_item_list(list):
	item_list = list
	if not list: 
		visible = false
		return
	else : visible = true

	for i in list:
		if not record_list.has(i):
			var new_record = record_proto.duplicate()
			add_child(new_record)
			move_child(new_record,0)
			new_record.set_item_name(ItemsEnum.Items.keys()[i])
			record_list[i] = new_record
			record_list[i].connect("selected", self, "_on_item_selected")
	
	update_list()

func update_list():
	if not item_list: return
	for i in item_list:
		var record = record_list[i]
		record.visible = (item_list[i] != 0)
		record.set_item_count(item_list[i])

func _on_item_selected(item_name):
	emit_signal("item_selected", item_name)
	
