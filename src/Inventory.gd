extends Node

onready var frontend = $"/root/Root/InventoryList"
var shop_area = null

const item_prices = {
	"Barrel":1,
	"Rum":1.5,
	"Fuel":0.2,
	"Planks":0.5,
	"CBall":0.1,
	#"Powder":0.1,
	"Food":0.1
}

var cash = 999
var inventory = {}

func _ready():
	assert(frontend)
	for i in item_prices:
		inventory[i] = 0
	
	load_inventory()
	frontend.call_deferred("update_front")
	
func shop_available(node):
	shop_area = node

func add_item(name:String, value:int):
	assert( inventory.has(name) )
	inventory[name] += value
	frontend.update_front()

func remove_item(name:String, value:int):
	assert( inventory.has(name) )
	inventory[name] -= value
	frontend.update_front()
		
func clear_inventory():
	for k in inventory.keys():
		inventory[k] = 0
		
func sell(item_name, count):
	if shop_area:
		shop_area.add_item(item_name,count)
		remove_item(item_name,count)
		var price = item_prices[item_name]*count
		cash += price
		
		frontend.update_front()

func buy(item_name, count):
	if shop_area:
		shop_area.remove_item(item_name,count)
		add_item(item_name,count)
		var price = item_prices[item_name]*count
		cash -= price
		
		frontend.update_front()

var save_dir = "res://save/"
var save_file = "res://save/inventory_save.txt"
func save_inventory():
	var dir = Directory.new()
	if not dir.dir_exists(save_dir):
		dir.make_dir(save_dir)
	
	var file = File.new()
	if file.open(save_file,File.WRITE) == OK:
		var save_content = { "Inventory":inventory, "Cash": cash }
		file.store_string(JSON.print(save_content))
		file.close()
		print("STORED")
	else:
		print("SAVING ERROR")

func load_inventory():
	var dir = Directory.new()
	if not dir.dir_exists(save_dir): return
	
	var file = File.new()
	if file.open(save_file,File.READ) == OK:
		var save_content = file.get_line()
		file.close()
		save_content = JSON.parse(save_content).result
		cash = save_content["Cash"]
		inventory = save_content["Inventory"]
		print("LOADED")
	else:
		print("LOADING ERROR")

#func _notification(what):
#	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
#		print("saving inventory")
#		save_inventory()
