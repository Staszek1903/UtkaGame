extends Node

onready var trade_interface = $"/root/TradeInterface"

var cash = 999
var inventory = {}

func _ready():
	assert(trade_interface)
	for i in ItemsEnum.Items.ITEM_COUNT:
		inventory[i] = 1000
	
#	load_inventory()


func add_item(item:int, value:int):
	assert( inventory.has(item) )
	inventory[item] += value


func remove_item(item:int, value:int):
	assert( inventory.has(item) )
	inventory[item] -= value


func clear_inventory():
	for k in inventory.keys():
		inventory[k] = 0

func get_quantity(item:int) -> int:
	assert( inventory.has(item) )
	return inventory[item]
	

############################
#   SAVING LOADING         #
############################

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
		var temp_inv = save_content["Inventory"]
		for key in temp_inv:
			inventory[int(key)] = temp_inv[key]
		print("LOADED")
	else:
		print("LOADING ERROR")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("saving inventory")
		save_inventory()
