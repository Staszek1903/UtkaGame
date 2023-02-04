extends Node

var boat_position:Vector3 = Vector3(100.0, 1.0, 0.1)
var cargo:Dictionary = {}
var boat_scene:PackedScene = null

var lug_scene = preload("res://scenes/boats/LugBoat.tscn")
var sloop_scene = preload("res://scenes/boats/SloopBoat.tscn")
var cutter_scene = preload("res://scenes/boats/Cutter.tscn")

func spawn_new_boat(boat_scene:PackedScene, origin:Vector3):
	var new_boat = boat_scene.instance()
	get_tree().get_root().add_child(new_boat)
	new_boat.global_transform.origin = origin
	return new_boat

func update_data(boat:RigidBody):
	var path:String = boat.get_parent().get_path()
	
	if path.find("Cutter") != -1:
		boat_scene = cutter_scene
	elif path.find("Sloop") != -1:
		boat_scene = sloop_scene
	elif path.find("Lug") != -1:
		boat_scene = lug_scene
		
	boat_position = boat.global_transform.origin
	
	var cargo_hold = boat.get_cargo()
	if cargo_hold:
		cargo = cargo_hold.items.duplicate()
	
		
func load_data():
	var file = File.new()
	if ERR_FILE_NOT_FOUND == file.open("user://savegame.save", File.READ):
		return
		
	var line = file.get_line()
	var save_data:Dictionary = JSON.parse(line).result

	boat_position = str2var(save_data.boat_position)
	cargo = save_data.cargo
	boat_scene = load(save_data.boat_scene)

func save_data():
	#if not boat_scene or not cargo: return
	var file = File.new()
	file.open("user://savegame.save", File.WRITE)
	var save_data:Dictionary = {
		boat_position = var2str(boat_position),
		cargo = cargo,
		boat_scene = boat_scene.resource_path
	}
	
	file.store_line(JSON.print(save_data))
	
func load_game():
	#if not boat_scene or not cargo: return
	
	var boat = spawn_new_boat(boat_scene,  boat_position).get_node("Boat")
	boat.get_cargo().add_items(cargo)
	
