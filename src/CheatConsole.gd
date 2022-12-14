extends LineEdit

onready var console_out = $ConsoleOut

func _input(event):
	if event is InputEventKey and event.pressed:
		match(event.scancode):
			KEY_TAB:
				visible = true
				grab_focus()
				get_tree().paused = true
			KEY_ESCAPE:
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
	assert(pivot.has_method("get_boat"))
	var boat = pivot.get_boat()
	return boat

func get_boat_hold():
	var boat = get_boat()
	var hold = boat.get_node("CargoHold")
	assert(hold)
	return hold
	
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

func help_(args = []):
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
	hold.add_items({item:count})
	

func unlockall_(args = []):
	get_tree().call_group("production_building", "set_state", 1)

func crew_(args = []):
	var quantity:int = 1
	if args.size() == 1 and args[0].is_valid_integer():
		quantity = int(args[0])
	var crew = get_boat().get_node("Crew")
	assert(crew)
	for i in quantity:
		crew.spawn()

func hit_(args = []):
	var quantity:int = 1
	if args.size() == 1 and args[0].is_valid_integer():
		quantity = int(args[0])
	var boat = get_boat()
	boat.receive_damage(quantity)

#func unlockprod_(args = []):
#	pass

func godmode_(args = []):
	var boat = get_boat()
	boat.godmode = not boat.godmode
	cout("godmode "+ str(boat.godmode))

#func tp_(args = []):
#	pass
	
