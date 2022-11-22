extends Position3D

signal mooring_on
signal mooring_off
signal action

onready var indicator = $Indicator
var indicator_visible:bool = false setget set_indicator_visible

func set_indicator_visible(val):
	indicator_visible = val
	indicator.visible = val

var docked_rope_end:Node = null setget set_docked_rope_end

func set_docked_rope_end(val:Node):
	var prev = docked_rope_end
	docked_rope_end = val
	if val and not prev:
		emit_signal("mooring_on")
		$IconBaner.visible = true
	elif not val and prev:
		emit_signal("mooring_off")
		$IconBaner.visible = false
	

func _process(delta):
	if docked_rope_end:
		docked_rope_end.global_transform = global_transform
#	if docked_rope:
#		docked_rope.apply_force(delta*200)

var lock = false
func _physics_process(delta):
	if $IconBaner.visible and Input.is_action_pressed("action"):
		$IconBaner.value+=1
	else:
		$IconBaner.value=0
		lock = false

	if $IconBaner.value == 100 and not lock:
		lock = true
		emit_signal("action")


func _on_DockPointArea_mouse_entered():
	self.indicator_visible = true


func _on_DockPointArea_mouse_exited():
	self.indicator_visible = false


func _on_DockPointArea_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if not docked_rope_end:
			get_tree().call_group("mooring", "request_docking_to_point", self)
		else:
			var end = docked_rope_end
			set_docked_rope_end(null)
			get_tree().call_group("mooring", "request_undocking_to_end", end)
