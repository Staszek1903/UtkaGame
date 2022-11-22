extends Node

onready var inventory = $"/root/Inventory"
onready var inventory_interface = $"/root/InventoryList"
onready var shop_interface = $"/root/ShopList"

var shop_area = null

const item_prices = {
	ItemsEnum.Items.BARREL:1.5,
	ItemsEnum.Items.FUEL:0.2,
	ItemsEnum.Items.PLANKS:0.5,
	ItemsEnum.Items.CBALL:0.1,
	ItemsEnum.Items.FOOD:0.1,
	ItemsEnum.Items.COGWHEEL:0.1,
}

func _ready():
	assert(inventory)
	assert(inventory_interface)
	assert(shop_interface)
	
	#inventory_interface.call_deferred("update_front")
	#shop_interface.call_deferred("update_front")

func get_price(item:int) -> float:
	if item_prices.has(item):
		return item_prices[item]
	else:
		return 1.0

func set_shop_area(node):
	shop_area = node
	shop_interface.shop_available(node)
	
func sell(item:int, quantity:int):
	print("selling ",quantity," of ",ItemsEnum.Items.keys()[item])
	if not shop_area:return
	if inventory.get_quantity(item) < quantity : return
	inventory.remove_item(item,quantity)
	shop_area.add_item(item,quantity)
	var price = get_price(item)*quantity
	inventory.cash += price
	
	inventory_interface.update_front()
	shop_interface.update_front()
	
	
	
func buy(item:int, quantity:int):
	print("buying ",quantity," of ",ItemsEnum.Items.keys()[item])
	if not shop_area:return
	var price = get_price(item)*quantity
	
	if price > inventory.cash: return
	inventory.add_item(item,quantity)
	shop_area.remove_item(item,quantity)
	inventory.cash -= price
	
	inventory_interface.update_front()
	shop_interface.update_front()

func update_shop_front():
	if shop_area:
		shop_interface.update_front()
