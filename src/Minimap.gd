extends TextureRect

signal maximized
signal minimized

onready var viewport: Viewport = $"../MinimapViewport"
var is_max:bool = false

func _ready():
	assert(viewport)
	
func _process(delta):
	if Input.is_action_just_pressed("toggle_map"):
		if is_max: minimize()
		else: maximize()
		is_max = not is_max

func maximize():
	emit_signal("maximized")
	var size = OS.get_window_size()
	size.x = size.y
	viewport.size = size
	$Tween.interpolate_property(self, "rect_size", rect_size,
								size, 1)
	$Tween.start()
	

func minimize():
	emit_signal("minimized")
	$Tween.interpolate_property(self, "rect_size", rect_size ,
								Vector2(150,150), 1)
	$Tween.start()
	viewport.size = Vector2(150,150)
