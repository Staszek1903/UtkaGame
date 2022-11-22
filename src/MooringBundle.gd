extends SteeringPoint

#var mooring_active:bool = false setget set_active
var mooring_casted:bool = false

onready var mooring:Node = $Mooring
onready var mooring_end:Node = $MooringEnd
onready var ind:Node = $Indicator
export(NodePath) onready var mooring_end_const = get_node(mooring_end_const)
export(float) var heave_force:float = 100.0


func _ready():
	steered_obj = get_path()
	heave_func_name = "heave_mooring"
	ease_func_name = "ease_mooring"
	#print("MOORING READY  ", steered_obj)

	add_to_group("mooring")
	assert(mooring_end)
	assert(mooring_end_const)
	
	mooring_end.global_transform = mooring_end_const.global_transform
	
	var parent = get_parent()
	if parent:
		mooring.atachmentNodeA = parent
		mooring.offsetA = transform.origin


func request_docking_to_point(point:Node):
	if mooring_casted: return
	var parent = get_parent()
	if parent.has_method("set_steering_point") \
	and parent.current_steering_point == self:
		point.set_docked_rope_end(mooring_end)
		#set_active(false)
		mooring_casted = true

func request_undocking_to_end(end:Node):
	if end != mooring_end: return
	end.global_transform = mooring_end_const.global_transform
	mooring_casted = false

func heave_mooring(delta):
	mooring.apply_force(delta*heave_force)
	#print("HEAVE")
	
func ease_mooring(delta):
	#print("EASE")
	pass
