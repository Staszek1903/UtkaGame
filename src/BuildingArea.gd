extends Node

signal stage_complete(nr)

#onready var player_inventory = $"/root/Inventory"
#onready var frontend = $"/root/BuildingList"

#export(Dictionary) var required_items = {}

var is_open:bool = false

export(Array, Resource) var stages:Array #= Array()
var current_stage = 0
var required_items

#onready var nodes_to_show = [$"../House/1Part",$"../House/2Part",$"../House/Roof"]



func _ready():
	#assert(player_inventory)
	#assert(frontend)
	assert(stages)
	
	required_items = stages[0]
	
func item_valid(item_name:int) ->bool:
	var inv = {} #player_inventory.inventory
	var a:bool = (item_name in required_items.item_names)
	var b:bool = (item_name in inv)
	var c:bool = inv[item_name] >= required_items.get_property(item_name,"quantity")
	return (a and b and c)

func process_item(item_name:int):
	#player_inventory.remove_item(item_name, required_items.get_property(item_name,"quantity"))
	required_items.remove(item_name)

func item_pressed(item_name:String):
	if not item_valid(ItemsEnum.Items[item_name]): return
	process_item(ItemsEnum.Items[item_name])
	
	if required_items.item_names.size() == 0:
		#nodes_to_show[current_stage].visible = true
		emit_signal("stage_complete",current_stage)
		current_stage += 1
		if current_stage < stages.size():
			required_items = stages[current_stage]
	
	#frontend.update_front()
	$"/root/InventoryList".update_front()


func open_building_area():
	is_open = true
	#frontend.building_available(self)


func close_building_area():
	is_open = false
	#frontend.building_available(null)
