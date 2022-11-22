tool
extends Node
class_name WaterManager

onready var mdt :MeshDataTool = MeshDataTool.new()
#onready var material = get_surface_material(0)
onready var shader_material = $"../WaterTile/WaterMesh".get_surface_material(0)
onready var tween:Tween = $Tween

export(float) var amplitude = 0.2 setget set_amplitude
export(float) var frequency = 0.3 setget set_frequency
export(float) var timefactor = 1.0

var default_amplitude = 0.2
var default_frequency = 0.3
var default_timefactor = 1.0

func _ready():
	assert(shader_material)
	default_amplitude = amplitude
	default_frequency = frequency
	default_timefactor = timefactor
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

func wave_height(pos : Vector2, loc_time : float) -> float:	
	return amplitude * sin(pos.x * frequency + loc_time * timefactor) \
	+ amplitude * sin(pos.y * frequency + loc_time * timefactor)

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

func set_next_amplitude(new_amplitude:float):
	#warning_ignore
	tween.interpolate_property(self,"amplitude", amplitude, new_amplitude, 
								abs(amplitude - new_amplitude) * 10,Tween.TRANS_CUBIC,
								Tween.EASE_IN_OUT)
	#warning_ignore
	tween.start()
	
func set_next_frequency(new_frequency:float):
	tween.interpolate_property(self,"frequency",frequency, new_frequency, 
								abs(frequency - new_frequency) * 10,Tween.TRANS_CUBIC,
								Tween.EASE_IN_OUT)
	tween.start()
	
func set_default_water_params():
	self.amplitude = default_amplitude
	self.frequency = default_frequency
	self.timefactor = default_timefactor
