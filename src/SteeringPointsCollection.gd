extends Spatial

signal current_changed(point)

onready var current_steering_point = get_child(0)

export(bool) var disable:bool = false setget set_disabled

func ready():
	assert(current_steering_point)
	
func set_disabled(val:bool):
	disable = val
	if disable:
		current_steering_point = null
		for c in get_children():
			c.indicator.visible = false
			c.is_manned = false
		emit_signal("current_changed", null)
	
func set_steering_point(point):
	if disable: return
	for c in get_children():
		c.indicator.visible = false
		c.is_manned = false
	current_steering_point = point
	point.indicator.visible = true
	emit_signal("current_changed", point)

func scroll_point(offset):
	if not current_steering_point: return
	var next_index = wrapi(
			current_steering_point.get_index() + offset,
			0,
			get_child_count()
			)
	set_steering_point(get_child(next_index))
	
func steer_heave(delta):
	if not current_steering_point: return
	current_steering_point.steer_heave(delta)
	
func steer_ease(delta):
	if not current_steering_point: return
	current_steering_point.steer_ease(delta)
	
	
	
