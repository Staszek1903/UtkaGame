extends Spatial
class_name SteeringPoint

signal heaved
signal eased

export(NodePath) var steered_obj
export(String) var heave_func_name
export(String) var ease_func_name
export(bool) var emit_rope_sound = true

var steered_node = null
#var heave_func: FuncRef
#var ease_func: FuncRef

onready var indicator = $Indicator
onready var label = $"/root/Ui/SteeringName"
onready var audio = $RopeSounds

export(bool) var is_man_required:bool = true
var is_manned:bool = false

func _ready():
	call_deferred("make_funcrefs")

var play_audio:int = 0
func _process(_delta):
	if play_audio > 0:
		play_audio -= 1
		print(play_audio)
		if audio and emit_rope_sound and not audio.playing: audio.playing = true
	else:
		if audio and emit_rope_sound: audio.playing = false
	
	
func make_funcrefs():
	var ib = $IconBaner
	if ib: ib.global_translate(Vector3(0,0.5,0))
	steered_node = get_node(steered_obj)
	#print("FUNCREFS")
#	var heave_func = funcref(steered_node, heave_func_name)
#	var ease_func = funcref(steered_node, ease_func_name)
#
#	assert(heave_func.is_valid())
#	assert(ease_func.is_valid())

	assert(steered_node.has_method(heave_func_name))
	assert(steered_node.has_method(ease_func_name))

func steer_heave(delta):
	if is_man_required and not is_manned: return
	#heave_func.call_func(delta)
	var result = steered_node.call(heave_func_name, delta)
	print("result: ", result)
	if result: 
		emit_signal("heaved")
		play_audio += 1
	
func steer_ease(delta):
	if is_man_required and not is_manned: return
	#ease_func.call_func(delta)
	var result = steered_node.call(ease_func_name, delta)
	print("result: ", result)
	if result: 
		emit_signal("eased")
		play_audio += 1

func _on_MouseArea_pressed():
	get_parent().set_steering_point(self)

func _on_MouseArea_mouse_hoover(is_hoovering):
	label.visible = is_hoovering
	label.text = name
