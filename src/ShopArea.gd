extends Node
class_name ShopArea

#onready var trade_interface = $"/root/TradeInterface"

export(Resource) var producing

var inventory = {}
var production_inventory = {}
var is_open = false

var production_stage:int = 0 setget set_production_stage
var production_time:float = 3.0
var production_base_time:float = 3.0
func _ready():
	assert(producing)
	#assert(trade_interface)
	for i in ItemsEnum.Items.values():
		inventory[i] = 0
		production_inventory[i] = 0.0
#	for i in producing.item_names:
#		assert(i in trade_interface.item_prices)

func set_production_stage(val: int):
	production_stage = val
	production_time = production_base_time / pow(1.5, float(production_stage))

var timer:float = 0.0
func _process(delta):
	timer += delta
	if timer >= production_time:
		timer = 0.0
		production()
		#trade_interface.update_shop_front()


func production():
	var items = producing.item_names
	for item in items:
		var quot = producing.get_property(item,"quotient")
		production_inventory[item] += quot
		
	for item in producing.item_names:
		inventory[item] += floor(production_inventory[item])
		production_inventory[item] -= int(floor(production_inventory[item]))
		var max_val = producing.get_property(item,"max_value")
		inventory[item] = clamp(inventory[item], 0, max_val)

func add_item(item:int, quantity:int):
	assert( inventory.has(item) )
	inventory[item] += quantity


func remove_item(item:int, quantity:int):
	assert( inventory.has(item) )
	inventory[item] -= quantity
	

func close_shop_area():
	is_open = false
	#trade_interface.set_shop_area(null)
	

func open_shop_area():
	is_open = true
	#trade_interface.set_shop_area(self)


func _on_BuildingArea_stage_complete(nr:int):
	set_production_stage(nr+1)
	
