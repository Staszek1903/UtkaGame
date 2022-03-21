tool
extends Node

onready var mdt :MeshDataTool = MeshDataTool.new()
#onready var material = get_surface_material(0)
onready var shader_material = $"../WaterTile/WaterMesh".get_surface_material(0)

export(float) var amplitude = 0.1 setget set_amplitude
export(float) var frequency = 1.0 setget set_frequency
export(float) var timefactor = 1.0

func _ready():
	pass
#	print(mesh.get_surface_count())
#	mdt.create_from_surface(mesh,0)
#	print(mdt.get_vertex_count())
#	print(mesh.get_surface_count())
	
	shader_material.set_shader_param("amplitude", amplitude)
	shader_material.set_shader_param("frequency", frequency)

func set_amplitude(var val: float):
	amplitude = val
	if shader_material: 
		shader_material.set_shader_param("amplitude", amplitude)

func set_frequency(var val: float):
	frequency = val
	if shader_material: 
		shader_material.set_shader_param("frequency", frequency)

func wave_height(pos : Vector2,time : float) -> float:	
	return amplitude * sin(pos.x * frequency + time * timefactor) \
	+ amplitude * sin(pos.y * frequency + time * timefactor)

var time : float = 0.0
func wave(global_pos : Vector2) -> float:
	return wave_height(global_pos, time)

func _process(delta):
	time += delta
#	for i in mdt.get_vertex_count():
#		var vert = mdt.get_vertex(i)
#		vert.y = wave_height(Vector2(vert.x, vert.z), time)
#		mdt.set_vertex(i, vert)
#
#	for i in mdt.get_face_count():
#		var v0i = mdt.get_face_vertex(i, 0)
#		var v1i = mdt.get_face_vertex(i, 1)
#		var v2i = mdt.get_face_vertex(i, 2)
#		var v0 = mdt.get_vertex(v0i)
#		var v1 = mdt.get_vertex(v1i)
#		var v2 = mdt.get_vertex(v2i)
#
#		var a = (v1-v0).normalized()
#		var b = (v2-v0).normalized()
#		var normal = b.cross(a).normalized()
#		mdt.set_vertex_normal(v0i, normal)
#		mdt.set_vertex_normal(v1i, normal)
#		mdt.set_vertex_normal(v2i, normal)
#
#	mdt.set_material(material)
#	mesh.surface_remove(0)
#	mdt.commit_to_surface(mesh)
	
	shader_material.set_shader_param("time", time * timefactor)
	
#	for i in get_child_count():
#		get_child(i).queue_free()
#	create_debug_tangents()
	pass
