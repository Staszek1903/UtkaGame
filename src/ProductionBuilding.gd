extends Spatial


#signal give_items(item_name, quantity)

export( Vip.Id ) var unlock_id = 0
export(String) var item_name = "Food"
export(float) var production_speed_ups:float = 2.0
enum{UNDISCOVERED, UNBUILT, BUILT}

var state = UNDISCOVERED
var lock_ui:bool = true setget set_lock_ui
var production_progress:float = 0.0 # value 0 to 1
var items_in_stock:int = 0 setget set_items_in_stock

func _ready():
	set_lock_ui(true)
	
func update_state():
	match(state):
		UNDISCOVERED:
			$Button3D.visible = false
		UNBUILT:
			$Button3D.visible = true
			$Button3D.text = "BUILD SHIT"
		BUILT:
			$Button3D.visible = true
			$IconBaner.visible = true
			#$Text3D.visible = true
			$Button3D.text = "GET RESOURCES"

func set_state(new_state):
	state = new_state
	update_state()
	
func set_lock_ui(val:bool):
	lock_ui = val
	if lock_ui:
		$Button3D.visible = false
		$IconBaner.visible = false
		#$Text3D.visible = false
	else:
		update_state()
		
func set_items_in_stock(val: int):
	items_in_stock = val
	$IconBaner.text = "%d" % [items_in_stock]

func _on_button_pressed():
	if lock_ui: return
	match(state):
		UNBUILT:
			set_state(BUILT)
		BUILT:
			print("GIVING items")
			give_items()

func give_items():
	var quantity = items_in_stock
	self.items_in_stock = 0
	get_parent().give_items(item_name, quantity, self)
	
	
func add_items(quantity:int):
	self.items_in_stock += quantity
	
func check_unlock_id(id:int):
	if state == UNDISCOVERED and id == unlock_id:
		set_state(UNBUILT)

	
func _process(delta:float):
	if state != BUILT: return
	production_progress += delta * production_speed_ups
	#print("prod:", production_progress)
	if production_progress >= 1.0:
		production_progress = 0
		self.items_in_stock += 1
	$IconBaner.value = int(production_progress * 100.0)
	

