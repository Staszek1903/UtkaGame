extends Spatial
class_name SteeringPoint

export(NodePath) var steered_obj
export(String) var heave_func_name
export(String) var ease_func_name

var heave_func: FuncRef
var ease_func: FuncRef

onready var indicator = $Indicator

func _ready():
	call_deferred("make_funcrefs")
	
func make_funcrefs():
	steered_obj = get_node(steered_obj)
	#print("FUNCREFS")
	heave_func = funcref(steered_obj, heave_func_name)
	ease_func = funcref(steered_obj, ease_func_name)
	
	assert(heave_func.is_valid())
	assert(ease_func.is_valid())

func steer_heave(delta):
	heave_func.call_func(delta)
	
func steer_ease(delta):
	ease_func.call_func(delta)

func _on_MouseArea_pressed():
	get_parent().set_steering_point(self)

