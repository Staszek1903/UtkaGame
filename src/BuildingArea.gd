extends Area

onready var player_inventory = $"/root/Root/Inventory"
onready var frontend = $"/root/Root/BuildingList"

#export(Dictionary) var required_items = {}

var stage1 = {
	"Planks": 10,
	"Barrel": 10,
	"CBall": 20
}

var stage2 = {
	"Planks": 5,
	"Barrel": 5,
	"CBall": 10
}

var stages = [ {}, stage1, stage2]
onready var nodes_to_show = [$"../House/1Part",$"../House/2Part",$"../House/Roof"]

var current_stage = 0

var required_items = {
	"Planks": 1,
	"Barrel": 1,
	"CBall": 2
}

func _ready():
	assert(player_inventory)
	assert(frontend)
	
func item_valid(item_name) ->bool:
	var inv = player_inventory.inventory
	var a:bool = (item_name in required_items)
	var b:bool = (item_name in inv)
	var c:bool = inv[item_name] >= required_items[item_name]
	return (a and b and c)

func process_item(item_name):
	player_inventory.remove_item(item_name, required_items[item_name])
	required_items.erase(item_name)

func item_pressed(item_name):
	if not item_valid(item_name): return
	process_item(item_name)
	
	if required_items.size() == 0:
		nodes_to_show[current_stage].visible = true
		current_stage += 1
		if current_stage < 3:
			required_items = stages[current_stage]
	
	frontend.update_front()

func _on_BuildingArea_body_entered(body):
	if body.name != "Boat": return
	frontend.building_available(self)

func _on_BuildingArea_body_exited(body):
	if body.name != "Boat": return
	frontend.building_available(null)
