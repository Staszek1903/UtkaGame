extends StaticBody

signal action
signal mooring_off
signal mooring_on

onready var quai_camera = $Camera
var boat_camera = null

var mooring_counter:int = 0

var upgrade_buildings = []

func _ready():
	for child in get_children():
		if child.has_method("update_requirements"):
			upgrade_buildings.append(child)

func _on_DockPoint_action():
	emit_signal("action")
	print("QUAI ACTION")
	
	switch_to_village_look()
	update_requirement_buildings()
	update_unlockables()
	
	
func _on_DockPoint_mooring_off():
	emit_signal("mooring_off")
	print("MOORING OFF")
	mooring_counter -= 1
	
	if boat_camera and mooring_counter == 0:
		switch_to_boat_look()
		
	


func _on_DockPoint_mooring_on():
	emit_signal("mooring_on")
	print("MOORING ON")
	mooring_counter += 1
	
func switch_to_village_look():
	if not quai_camera: return
	if quai_camera.current: return
	boat_camera = get_viewport().get_camera()	
	quai_camera.current = true
	
	for child in get_children():
		if child.has_method("set_lock_ui"):
			child.set_lock_ui(false)
	
func switch_to_boat_look():
	boat_camera.current = true
	boat_camera = null
	
	for child in get_children():
		if child.has_method("set_lock_ui"):
			child.set_lock_ui(true)
			
func get_boat():
	var pivot = boat_camera.get_parent()
	assert(pivot.has_method("get_boat"))
	var boat = pivot.get_boat()
	return boat
			
func get_boat_hold():
	var pivot = boat_camera.get_parent()
	assert(pivot.has_method("get_boat"))
	var boat = pivot.get_boat()
	var hold = boat.get_node("CargoHold")
	assert(hold)
	return hold


func give_items(item_name:String, quantity:int, building:Spatial):
	var hold = get_boat_hold()
	var cap = hold.get_capacity(item_name)
	var count = hold.get_item_count(item_name)
	var avail = cap - count
	if quantity > avail:
		building.add_items(quantity - avail)
		quantity = avail
	hold.add_items({item_name:quantity})
	update_requirement_buildings()
	
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