extends Area
class_name ShopArea

onready var player_inventory = $"/root/Root/Inventory"
onready var frontend = $"/root/Root/ShopList"

export(Array,String) var producing = []
#export(Array, float) var price_quotient = []

var inventory = {}

func _ready():
	assert(player_inventory)
	assert(frontend)
	for i in player_inventory.item_prices:
		inventory[i] = 0
	for i in producing:
		assert(i in player_inventory.item_prices)
		inventory[i] = 100

func add_item(name:String, value:int):
	assert( inventory.has(name) )
	inventory[name] += value
	frontend.update_front()

func remove_item(name:String, value:int):
	assert( inventory.has(name) )
	inventory[name] -= value
	frontend.update_front()
	
func sell(item_name, count):
	player_inventory.buy(item_name,count)

func _on_ShopArea_body_exited(body):
	if body.name != "Boat": return
	frontend.shop_available(null)
	player_inventory.shop_available(null)

func _on_ShopArea_body_entered(body):
	if body.name != "Boat": return
	frontend.shop_available(self)
	player_inventory.shop_available(self)
