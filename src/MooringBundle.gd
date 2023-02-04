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

var current_point:Spatial = null

func request_docking_to_point(point:Spatial):
	if mooring_casted: return
	if distance_to(point) > mooring.max_length: return
	
	var parent = get_parent()
	if parent.has_method("set_steering_point") \
	and parent.current_steering_point == self:
		point.docked_boat = get_parent().get_parent()
		point.set_docked_rope_end(mooring_end)
		#set_active(false)
		mooring_casted = true
		mooring.update_ends_pos()
		mooring.set_length(-1.0)
		current_point = point

func request_undocking_to_end(point:Spatial):
	if not point: return
	var parent = get_parent()
	if parent.has_method("set_steering_point") \
	and parent.current_steering_point == self:
		var end = point.docked_rope_end
		if end != mooring_end: return
		point.set_docked_rope_end(null)
		end.global_transform = mooring_end_const.global_transform
		mooring_casted = false
		mooring.update_ends_pos()
		mooring.set_length(-1.0)
		current_point = null
	
func is_in_distance(response:Dictionary):
	#print("IS IN DISTACJE FUNC")
	response["resps"] += 1
	var point = response["point"]
	var parent = get_parent()
	if parent.has_method("set_steering_point") \
	and parent.current_steering_point == self:
		if mooring_casted:
			response["result"] = false
			return
		if distance_to(point) > mooring.max_length:
			response["result"] = false
			return
		response["result"] = true
	
	

func heave_mooring(delta):
	mooring.length -= 0.5 * delta
	#mooring.apply_force(delta*heave_force)
	print("HEAVE ", mooring.length)
	
func ease_mooring(delta):
	mooring.length += 0.5 * delta
	print("EASE ", mooring.length)
	
func distance_to(point: Spatial) -> float:
	var a = global_transform.origin
	var b = point.global_transform.origin
	return (a-b).length()

#onready var label = $"/root/Ui/SteeringName"
func _on_MooringTrigger_mouse_hoover(is_hoovering):
	label.visible = is_hoovering
	label.text = "Mooring"
