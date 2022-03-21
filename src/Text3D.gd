tool
extends Spatial

onready var label = $Viewport/LabelScene/Label
onready var colorrect = $Viewport/LabelScene/ColorRect
onready var mesh = $MeshInstance
onready var viewport = $Viewport

export(Vector2) var dimentions = Vector2(1,1) setget set_dimentions
export(int) var resolution = 100 setget set_resolution
export(String) var text = "SAMPLE TEXT" setget set_text
export(Color) var bg_color = Color(0.262745, 0.12549, 0.007843) setget set_bg_color

func _ready():
	set_text(text)
	set_bg_color(bg_color)
	set_dimentions(dimentions)
	set_resolution(resolution)

func set_text(val:String):
	text = val
	if label: label.text = val
	
func set_bg_color(val:Color):
	bg_color = val
	if colorrect: colorrect.color = val
	
func set_dimentions(val:Vector2):
	dimentions = val
	if mesh: mesh.mesh.size = val
	if viewport: viewport.size = val * resolution

func set_resolution(val:int):
	resolution = val
	if viewport: viewport.size = dimentions * val
