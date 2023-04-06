tool
extends Spatial

onready var label = $Viewport/KeyIcon/Label
onready var key_icon = $Viewport/KeyIcon
onready var mesh = $MeshInstance
onready var viewport = $Viewport

export(Vector2) var dimentions = Vector2(1,1) setget set_dimentions
export(int) var resolution = 100 setget set_resolution
export(String) var text = "0" setget set_text
export(int,0,100) var value = 0 setget set_value

func _ready():
	set_dimentions(dimentions)
	set_resolution(resolution)
	set_text(text)
	
func set_dimentions(val:Vector2):
	dimentions = val
	if mesh: mesh.mesh.size = val
	if viewport: viewport.size = val * resolution

func set_resolution(val:int):
	resolution = val
	if viewport: viewport.size = dimentions * val

func set_text(val:String):
	text = val
	if label: label.text = val

func set_value(val:int):
	value = val
	if key_icon: key_icon.value = val
