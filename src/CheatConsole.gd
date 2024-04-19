extends LineEdit

onready var console_out = $ConsoleOut

var load_on_new_scene:bool = false
var mouse_y_inverted:bool = true

func check_load():
	if load_on_new_scene:
		call_deferred("load_", [])

#func _ready():
#	var file = File.new()
#	if file.file_exists("user://savegame.save"):
#		call_deferred("load_", [])

func _input(event):
	if event is InputEventKey and event.pressed:
		match(event.scancode):
			KEY_F9:
				visible = true
				grab_focus()
				get_tree().paused = true
			KEY_ESCAPE:
				if not visible: return
				console_out.visible = false
				visible = false
				get_tree().paused = false
			KEY_ENTER:
				if visible: exec_command()
				
func get_timestamp() -> String:
	var t = OS.get_time()
	return (
		"["+
		str(t["hour"])+
		":"+
		str(t["minute"])+
		":"+
		str(t["second"])+
		"]"
		)
				
func exec_command():
	cout(get_timestamp()+">"+text)
	var words = text.split(" ", false)
	text = ""
	
	if words.size() == 0: return
	
	var cmd = words[0] + "_"
	words.remove(0)
	
	if not has_method(cmd):
		cout("USUPORTED COMMAND: " + cmd.rstrip("_"))
		return
	
	call(cmd, words)
	
	
func cout(s):
	console_out.visible = true
	console_out.text += "\n" + str(s)
	console_out.scroll_vertical = console_out.text.count("\n")

func get_boat():
	var pivot = get_viewport().get_camera().get_parent()
	if not pivot or not pivot.has_method("get_boat"):
		return null
	var boat = pivot.get_boat()
	return boat

func get_boat_hold():
	var boat = get_boat()
	var hold = boat.get_node("CargoHold")
	assert(hold)
	return hold
	
var lug_scene = preload("res://scenes/boats/LugBoat.tscn")
var sloop_scene = preload("res://scenes/boats/SloopBoat.tscn")
var cutter_scene = preload("res://scenes/boats/Cutter.tscn")

func spawn_new_boat(boat_scene:PackedScene, old_boat:Spatial, origin:Vector3):
	old_boat.get_parent().queue_free()
	var new_boat = boat_scene.instance()
	get_tree().get_root().add_child(new_boat)
	new_boat.global_transform.origin = origin
	
#################################################
#					COMMANDS					#
#################################################

#{
#	args:[{class_name:, hint:0, hint_string:, name:arg0, type:0, usage:7}],
#	default_args:[],
#	flags:65,
#	id:0,
#	name:unlockall_,
#	return:{class_name:, hint:0, hint_string:, name:, type:0, usage:7}
#}

func help_(_args = []):
	for m in get_method_list():
		var name = m["name"]
		if name[name.length()-1] == "_":
			cout(name.rstrip("_"))

func give_(args = []):
	if args.size() == 0:
		cout("usage: give <item> (<count>)")
		return
	
	var item = args[0].capitalize()
	var count = 16
	
	if args.size() >= 2:
		if args[1].is_valid_integer():
			count = int(args[1])
		else:
			cout("args 2 expected to be valid integer")
			return
	
	var hold = get_boat_hold()
	var result = hold.add_items({item:count})
	if not result: cout("%s not in capacity" % [item])

func capacity_(args = []):
	var hold = get_boat_hold()
	for name in hold.capacity:
		cout("%s: %d" % [name, hold.capacity[name]])

func unlockall_(_args = []):
	get_tree().call_group("production_building", "set_state", 1)

func crew_(args = []):
	var quantity:int = 1
	if args.size() == 1 and args[0].is_valid_integer():
		quantity = int(args[0])
	var crew = get_boat().get_node("Crew")
	assert(crew)
	for i in quantity:
		crew.spawn()
		
func cannon_(args = []):
	var quantity:int = 6
	if args.size() == 1 and args[0].is_valid_integer():
		quantity = int(args[0])
	
	var cannons = get_boat().get_node("Cannons")
	if not cannons: return
	
	for i in quantity:
		cannons.add_cannon()

func hit_(args = []):
	var quantity:int = 1
	if args.size() == 1 and args[0].is_valid_integer():
		quantity = int(args[0])
	var boat = get_boat()
	boat.receive_damage(quantity)

#func unlockprod_(args = []):
#	pass

func godmode_(_args = []):
	var boat = get_boat()
	boat.godmode = not boat.godmode
	cout("godmode "+ str(boat.godmode))

func tp_(args = []):
	if args.size() != 2:
		cout("usage: tp <x> <y>")
		return

	if not args[0].is_valid_float() \
	or not args[1].is_valid_float():
		cout("args expected to be valid floats")
		return

	var x = float(args[0])
	var y = float(args[1])
	
	var old_boat:RigidBody = get_boat()
	var origin = Vector3(x, 1.0, y)
	var path:String = old_boat.get_parent().get_path()
	var scene = null
	if path.find("Cutter") != -1:
		scene = cutter_scene
	elif path.find("Sloop") != -1:
		scene = sloop_scene
	elif path.find("Lug") != -1:
		scene = lug_scene
	if scene:
		spawn_new_boat(scene, old_boat, origin)


func cutter_(_args = []):
	var old_boat = get_boat()
	var origin = old_boat.global_transform.origin
	spawn_new_boat(cutter_scene,old_boat,origin)
	
func sloop_(_args = []):
	var old_boat = get_boat()
	var origin = old_boat.global_transform.origin
	spawn_new_boat(sloop_scene,old_boat,origin)
	
func lug_(_args = []):
	var old_boat = get_boat()
	var origin = old_boat.global_transform.origin
	spawn_new_boat(lug_scene,old_boat,origin)
	
	
func save_(_args = []):
	var save_manager = $"/root/Root/SaveManager"
	if not save_manager: return
	var boat = get_boat()
	save_manager.update_data(boat)
	save_manager.save_data()
	
func load_(_args = []):
	var save_manager = $"/root/Root/SaveManager"
	if not save_manager: return
	var boat = get_boat()
	if boat: boat.delete_current()
	save_manager.load_data()
	save_manager.load_game()

func unsave_(_args = []):
	var dir = Directory.new()
	dir.remove("user://savegame.save")

	
func sepuku_(_args = []):
	var boat = get_boat()
	boat.set_floaters_enabled(false)
