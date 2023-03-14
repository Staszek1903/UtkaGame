extends Spatial
export(Array, String) var item_names = ["Food", "Wood", "Fabric",
	"Steel", "CannonBall"]

var lock_ui:bool = true setget set_lock_ui
var used:bool = false

func _ready():
	$Button3D.text = "LOOT"
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
	if lock_ui or used: return
	
	print("GIVING items")
	$Chest/AnimationPlayer.play("open")
	give_items()
	$Button3D.active = false

func give_items():
	var count = (randi() % 3) + 1
	#print("count: ", count)
	for i in count:
		var name_i = randi() % item_names.size()
		get_parent().give_items(item_names[name_i], 1, self)
		
	#queue_free()
	used = true
	
	
func add_items(quantity:int):
	pass
	
#func check_unlock_id(id:int):
#	if state == UNDISCOVERED and id == unlock_id:
#		set_state(UNBUILT)

func force_unlock():
	pass
#	if state == UNDISCOVERED:
#		set_state(UNBUILT)
	

