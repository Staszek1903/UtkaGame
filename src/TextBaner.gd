#tool
extends Spatial

onready var viewport = $Viewport
onready var label = $Viewport/Label
onready var mesh = $MeshInstance


export(Vector2) var dimentions = Vector2(1,1) setget set_dimentions
export(int) var resolution = 100 setget set_resolution
export(String) var text = "F" setget set_text

func _ready():
	set_dimentions(dimentions)
	set_resolution(resolution)
	
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
