extends Spatial

onready var current_steering_point = get_child(0)

func ready():
	assert(current_steering_point)

func set_steering_point(point):
	for c in get_children():
		c.indicator.visible = false
	current_steering_point = point
	point.indicator.visible = true
	
func scroll_point(offset):
	var next_index = wrapi(
			current_steering_point.get_index() + offset,
			0,
			get_child_count()
			)
	set_steering_point(get_child(next_index))
	
func steer_heave(delta):
	current_steering_point.steer_heave(delta)
	
func steer_ease(delta):
	current_steering_point.steer_ease(delta)
	
	
