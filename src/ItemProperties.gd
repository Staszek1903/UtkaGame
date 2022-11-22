tool
extends Resource
class_name ItemProperties

export(Array, ItemsEnum.Items) var item_names = [] setget set_item_names
export(Array, String) var item_properties = [] setget set_item_properties
export(Dictionary) var properties_db = {} setget set_properties_db

func set_item_names(val):
	item_names = val
	update_db()


func set_item_properties(val):
	item_properties = val
	update_db()


func set_properties_db(val):
	properties_db = val
	update_db()


func update_db():
	# add new item and props names
	for name in item_names:
		if not properties_db.has(name): properties_db[name] = Dictionary()
		for prop_name in item_properties:
			if not properties_db[name].has(prop_name):
				properties_db[name][prop_name] = 0.0
	
	#remove unwanted item and props names
	for name in properties_db:
		if not item_names.has(name): properties_db.erase(name)
		else: for prop_name in properties_db[name]:
			if not item_properties.has(prop_name):
				properties_db[name].erase(prop_name)
				
				
func get_property(item_name:int, property:String):
	return properties_db[item_name][property]
	
func remove(item:int):
	item_names.erase(item)
	update_db()
