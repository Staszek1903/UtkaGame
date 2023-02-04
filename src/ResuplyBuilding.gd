extends Spatial
export(String) var item_name = "Food"

var lock_ui:bool = true setget set_lock_ui

func _ready():
	$Button3D.text = "GET " + item_name.to_upper()
	set_lock_ui(true)
	add_to_group("production_building")

	
func set_lock_ui(val:bool):
	lock_ui = val
	print("SET LOCK UI: ", val)
	
	$Button3D.visible = not val
	#$IconBaner.visible = not val
	#$Text3D.visible = false
		
#func set_items_in_stock(val: int):
#	items_in_stock = val
#	$IconBaner.text = "%d" % [items_in_stock]

func _on_button_pressed():
	if lock_ui: return
	
	print("GIVING items")
	give_items()

func give_items():
	var quantity = 9999
	#self.items_in_stock = 0
	get_parent().give_items(item_name, quantity, self)
	
	
func add_items(quantity:int):
	pass
	
#func check_unlock_id(id:int):
#	if state == UNDISCOVERED and id == unlock_id:
#		set_state(UNBUILT)

func force_unlock():
	pass
#	if state == UNDISCOVERED:
#		set_state(UNBUILT)
	

