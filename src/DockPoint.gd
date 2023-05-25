extends Position3D

signal mooring_on(boat)
signal mooring_off(boat)
#signal action(boat)

onready var indicator = $Indicator
var indicator_visible:bool = false setget set_indicator_visible
var docked_boat = null

func set_indicator_visible(val):
	indicator_visible = val
	indicator.visible = val

var docked_rope_end:Node = null setget set_docked_rope_end

func set_docked_rope_end(val:Node):
	assert(docked_boat)
	var prev = docked_rope_end
	docked_rope_end = val
	if val and not prev:
		docked_rope_end.global_transform = global_transform
		emit_signal("mooring_on", docked_boat)
		#$IconBaner.visible = true
	elif not val and prev:
		emit_signal("mooring_off", docked_boat)
		docked_boat = null
		#$IconBaner.visible = false
	

func _process(_delta):
	if docked_rope_end and is_instance_valid(docked_rope_end):
		docked_rope_end.global_transform = global_transform
#	if docked_rope:
#		docked_rope.apply_force(delta*200)

#var lock = false
#func _physics_process(_delta):
#	if $IconBaner.visible and Input.is_action_pressed("action"):
#		$IconBaner.value+=1
#	else:
#		$IconBaner.value=0
#		lock = false
#
#	if $IconBaner.value == 100 and not lock:
#		lock = true
#		emit_signal("action", docked_boat)


func _on_DockPointArea_mouse_entered():
	if not docked_rope_end:
		var response = {"point": self, "resps":0, "result":false}
		#print("beforre resp ", response)
		get_tree().call_group("mooring", "is_in_distance", response)
		call_deferred("wait_for_response", response)
	else:
		self.indicator_visible = true
	
func wait_for_response(response:Dictionary):
	#print("after resp ",response)
	self.indicator_visible = response["result"]


func _on_DockPointArea_mouse_exited():
	self.indicator_visible = false


func _on_DockPointArea_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if not docked_rope_end:
			if self.indicator_visible:
				get_tree().call_group("mooring", "request_docking_to_point", self)
		else:
			if self.indicator_visible:
				get_tree().call_group("mooring", "request_undocking_to_end", self)
