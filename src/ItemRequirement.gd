tool
extends Spatial

export(String) var item_name = "" setget set_item_name
export(int) var quantity = 0 setget set_quantity
var available:int = 0 setget set_available

func _ready():
	add_to_group("item_requirement")
	
func set_item_name(val:String):
	item_name = val
	call_deferred("update_text")
	
func set_quantity(val:int):
	quantity = val
	call_deferred("update_text")
	
func set_available(val:int):
	available = val
	update_text()
	
func update_text():
	$TextBanner.text = "%s : %d/%d" % [item_name, 
	available,  quantity]
	
func satisfied() ->bool :
	return available >= quantity
