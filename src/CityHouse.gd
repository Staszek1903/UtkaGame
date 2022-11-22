tool
extends Spatial

onready var level1 = $Level1
onready var level_up = $LevelUP
onready var roofs = [$Roof, $Roof2, $Roof3]
onready var chimneys = [null, $Chimney, $Chimney2]
onready var roof_window = $RoofWindow
onready var wall_material = level1.get_active_material(0)

export(int,0,10) var height = 0 setget set_height
export(int,0,2) var roof_ind = 0 setget set_roof
export(int,0,2) var chimney_ind = 0 setget set_chimney
export(bool) var has_roof_window = false setget set_roof_window
export(Color) onready var wall_color = wall_material.albedo_color setget set_wall_color

var levels:Array = []
onready var roof_node = roofs[0]
onready var chimney_node = chimneys[0]

func _ready():
	assert(level1)
	assert(level_up)
	assert(roof_window)
	
	wall_material = wall_material.duplicate()
	level1.set_surface_material(0, wall_material)
	level_up.set_surface_material(0,wall_material)
	roof_window.set_surface_material(0, wall_material)
	roofs[0].set_surface_material(0, wall_material)
	chimneys[1].set_surface_material(0, wall_material)
	chimneys[2].set_surface_material(0, wall_material)
	
	randomize()
	set_height(randi()%6)
	set_roof(randi()%3)
	set_chimney(randi()%3)
	set_roof_window(randi()%4)
	set_wall_color(Color(randf(),randf(),randf()))
	
func set_height(val:int):
	if not level1: return
	height = val
	while(height > levels.size()):
		var newlvl = level_up.duplicate()
		newlvl.transform.origin = Vector3(0, 2.5*(levels.size()+1),0)
		add_child(newlvl)
		levels.append(newlvl)
		newlvl.visible = true
		
	while(height < levels.size()):
		var lvl = levels.pop_back()
		lvl.queue_free()
		
	set_roof(roof_ind)
	set_chimney(chimney_ind)
	set_roof_window(has_roof_window)

func set_roof(val:int):
	if not level1: return
	roof_ind = val
	roof_node.visible = false
	roof_node = roofs[val]
	roof_node.visible = true
	roof_node.transform.origin = Vector3(0, 2.5*(levels.size()+1),0)
	
func set_chimney(val:int):
	if not level1: return
	chimney_ind = val
	if chimney_node: 
		chimney_node.visible = false
	chimney_node = chimneys[val]
	if chimney_node:
		chimney_node.visible = true
		chimney_node.transform.origin.y = 2.5*(levels.size()+1)
	
func set_roof_window(val:bool):
	if not level1: return
	has_roof_window = val
	roof_window.visible = val
	roof_window.transform.origin.y = 2.5*(levels.size()+1)
	
func set_wall_color(val:Color):
	if not level1: return
	wall_color = val
	wall_material.albedo_color = val
