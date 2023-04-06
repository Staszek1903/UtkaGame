extends Node

var boat_position:Vector3 = Vector3(100.0, 1.0, 0.1)
var boat_rotation:Basis = Basis()
var cargo:Dictionary = {}
var cannons:int = 0
var shortcuts: Dictionary = {}
var boat_scene:PackedScene = null

var lug_scene = preload("res://scenes/boats/LugBoat.tscn")
var sloop_scene = preload("res://scenes/boats/SloopBoat.tscn")
var cutter_scene = preload("res://scenes/boats/Cutter.tscn")

onready var uimessages = $"/root/Ui/UIMessages"

func _ready():
	$"/root/Ui/CheatConsole".check_load()

func spawn_new_boat(_boat_scene:PackedScene,
			origin:Vector3,
			basis:Basis = Basis()):
	var new_boat = _boat_scene.instance()
	get_tree().get_root().add_child(new_boat)
	new_boat.global_transform.origin = origin
	new_boat.global_transform.basis = basis
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
	boat_rotation = boat.global_transform.basis
	
	var cargo_hold = boat.get_cargo()
	if cargo_hold:
		cargo = cargo_hold.items.duplicate()
		
	var cannons_node = boat.get_cannons()
	if cannons_node:
		cannons = cannons_node.cannons_count
	
	var control = boat.get_parent().get_node("Control")
	if control:
		var asigned:Dictionary = control.points_asigned
		for sc in asigned.keys():
			if asigned[sc]:
				shortcuts[sc] = asigned[sc].get_index()
		
func load_data():
	var file = File.new()
	if ERR_FILE_NOT_FOUND == file.open("user://savegame.save", File.READ):
		return
		
	var line = file.get_line()
	var save_data:Dictionary = JSON.parse(line).result

	boat_position = str2var(save_data.boat_position)
	boat_rotation = str2var(save_data.boat_rotation)
	cargo = save_data.cargo
	boat_scene = load(save_data.boat_scene)
	cannons = save_data.cannons
	for sc in save_data.shortcuts:
		shortcuts[int(sc)] = save_data.shortcuts[sc]

func save_data():
	#if not boat_scene or not cargo: return
	var file = File.new()
	file.open("user://savegame.save", File.WRITE)
	var save_data:Dictionary = {
		boat_position = var2str(boat_position),
		boat_rotation = var2str(boat_rotation),
		cargo = cargo,
		boat_scene = boat_scene.resource_path,
		cannons = cannons,
		shortcuts = shortcuts
	}
	
	file.store_line(JSON.print(save_data))
	
	uimessages.display("GAME SAVED", Color.green)
	
func load_game():
	#if not boat_scene or not cargo: return
	
	var boat = spawn_new_boat(boat_scene,  boat_position, boat_rotation) \
	.get_node("Boat")
	boat.get_cargo().add_items(cargo)
	var cannons_node = boat.get_cannons()
	if cannons_node:
		cannons_node.cannons_count = cannons
	
	var control = boat.get_parent().get_node("Control")
	var points_colection = control.steering_points
	#var assigned:Dictionary = {}
	if control and points_colection:
		var keys = shortcuts.keys()
		for sc in keys:
			var index = shortcuts[sc]
			var point_node = points_colection.get_child(index)
			
			points_colection.current_steering_point = point_node
			control.assign_steering_point(sc)
