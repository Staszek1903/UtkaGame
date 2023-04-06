extends Spatial

var is_eased:bool = false
var is_heaved:bool = false

export(float) var speed:float = 2.0

func _process(delta):
	if is_eased:
		rotate_y(speed * delta)
	if is_heaved:
		rotate_y(-speed * delta)

	is_eased = false
	is_heaved = false

func _on_eased():
	print("eased")
	is_eased = true

func _on_heaved():
	print("heaved")
	is_heaved = true
