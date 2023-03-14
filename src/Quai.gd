extends StaticBody

signal action
signal mooring_off
signal mooring_on

export(String, MULTILINE) var diary_message = null
#onready var quai_camera = $Camera
onready var diary = $"/root/Ui/Diary"
onready var save_manager = $"/root/Root/SaveManager"
#var boat_camera = null


var previously_visited:bool = false
var mooring_counter:Dictionary = {}
var last_boat = null

var upgrade_buildings = []

func _ready():
	for child in get_children():
		if child.has_method("update_requirements"):
			upgrade_buildings.append(child)

func _on_DockPoint_action(boat):
	emit_signal("action")
	print("QUAI ACTION ", boat)
	
#	switch_to_village_look()
#	update_requirement_buildings()
#	update_unlockables()
	
	
func _on_DockPoint_mooring_off(boat):
	emit_signal("mooring_off")
	print("MOORING OFF ", boat)
	checkout_boat(boat)
	
	if mooring_counter[boat] == 0:
		switch_to_boat_look(boat)
		save_manager.update_data(boat)
		save_manager.save_data()
	
	
func _on_DockPoint_mooring_on(boat):
	emit_signal("mooring_on")
	print("MOORING ON ", boat)
	log_boat(boat)
	
	switch_to_village_look()
	update_requirement_buildings()
	update_unlockables()
	update_diary()
	

	
func log_boat(boat):
	if boat in mooring_counter:
		mooring_counter[boat] += 1
	else:
		mooring_counter[boat] = 1
		
	last_boat = boat
	save_manager.update_data(boat)
	save_manager.save_data()
	
		
func checkout_boat(boat):
	if not boat in mooring_counter: return
	mooring_counter[boat] -= 1
	
	
func switch_to_village_look():
	for child in get_children():
		if child.has_method("set_lock_ui"):
			child.set_lock_ui(false)
	
#	if not quai_camera: return
#	if quai_camera.current: return
##	boat_camera = get_viewport().get_camera()	
#	quai_camera.current = true
	
	
	
func switch_to_boat_look(boat):
	boat.set_current()
#	boat_camera.current = true
#	boat_camera = null
	
	for child in get_children():
		if child.has_method("set_lock_ui"):
			child.set_lock_ui(true)

func update_diary():
	if previously_visited: return
	previously_visited = true
	
	print(diary_message)
	if diary_message:
		diary.add_content(diary_message.c_unescape())
	
	
			
func get_boat():
#	var pivot = boat_camera.get_parent()
#	assert(pivot.has_method("get_boat"))
#	var boat = pivot.get_boat()
#	return boat
	return last_boat
			
func get_boat_hold():
	var boat = get_boat()
	var hold = boat.get_node("CargoHold")
	assert(hold)
	return hold


func give_items(item_name:String, quantity:int, building:Spatial):
	if item_name == "Crew":
		give_crew()
		return
	
	if item_name == "Cannon":
		give_cannon()
		return

	var hold = get_boat_hold()
	var cap = hold.get_capacity(item_name)
	var count = hold.get_item_count(item_name)
	var avail = cap - count
	if quantity > avail:
		building.add_items(quantity - avail)
		quantity = avail
	hold.add_items({item_name:quantity})
	update_requirement_buildings()
	
func give_crew():
	var crew = get_boat().get_node("Crew")
	assert(crew)
	crew.spawn()
	
func give_cannon():
	var cannons = get_boat().get_node("Cannons")
	if not cannons: return
	cannons.add_cannon()
	
func withdraw_items(item_name, quantity):
	var hold = get_boat_hold()
	hold.withdraw_items({item_name:quantity})
	
	update_requirement_buildings()
	
func get_item_count(item_name):
	var hold = get_boat_hold()
	return hold.get_item_count(item_name)
	
func update_requirement_buildings():
	for b in upgrade_buildings:
		b.update_requirements()
		
func update_unlockables():
	var boat = get_boat()
	var vip = boat.get_vip()
	if vip: boat.release_vip()
	else: return
	
	for c in get_children():
		if c.has_method("check_unlock_id"):
			c.check_unlock_id(vip.unlock_id)
	
	vip.queue_free()
