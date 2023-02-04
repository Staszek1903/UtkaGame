tool
extends Node
class_name WaterManager

onready var mdt :MeshDataTool = MeshDataTool.new()
#onready var material = get_surface_material(0)
onready var water_mesh = $"../WaterMesh"
onready var shader_material = water_mesh.get_surface_material(0)
onready var island_manager = $"../IslandsManager"
#onready var tween:Tween = $Tween

export(float) var amplitude = 0.2 setget set_amplitude
export(float) var frequency = 0.3 setget set_frequency
export(float) var timefactor = 1.0
export(float) var direction = 0.0 setget set_direction
export(bool) var dynamic_amplitude:bool = true

var first_wave_dir = 0.0
var second_wave_dir = 0.0

var default_amplitude = 0.2
var default_frequency = 0.3
var default_timefactor = 1.0

func _ready():
	assert(shader_material)
	#assert(island_manager)
	default_amplitude = amplitude
	default_frequency = frequency
	default_timefactor = timefactor
#	print(mesh.get_surface_count())
#	mdt.create_from_surface(mesh,0)
#	print(mdt.get_vertex_count())
#	print(mesh.get_surface_count())
	
	shader_material.set_shader_param("amplitude", amplitude)
	shader_material.set_shader_param("frequency", frequency)
	set_direction(direction)

func set_amplitude(var val: float):
	amplitude = val
	if shader_material: 
		shader_material.set_shader_param("amplitude", amplitude)

func set_frequency(var val: float):
	frequency = val
	if shader_material: 
		shader_material.set_shader_param("frequency", frequency)

func set_direction(var val: float):
	direction = val
	first_wave_dir = direction - PI * 0.125
	second_wave_dir = direction + PI * 0.125
	if shader_material: 
		shader_material.set_shader_param("first_wave_dir",
		 first_wave_dir)
		shader_material.set_shader_param("second_wave_dir",
		 second_wave_dir)
		

func first_dir(pos: Vector2) -> float:
	var dirx = cos(first_wave_dir)
	var diry = sin(first_wave_dir)
	return (dirx * pos.x + diry * pos.y)

func second_dir(pos: Vector2) -> float:
	var dirx = cos(second_wave_dir)
	var diry = sin(second_wave_dir)
	return (dirx * pos.x + diry * pos.y)

func wave_height(pos : Vector2, loc_time : float) -> float:
	return amplitude * sin(first_dir(pos) * frequency + loc_time * timefactor) \
	+ amplitude * sin(second_dir(pos) * frequency + loc_time * timefactor)

var time : float = 0.0
const vertical_wave_trim:float = 0.3
func wave(global_pos : Vector2) -> float:
	return wave_height(global_pos, time) + vertical_wave_trim

func _process(delta):
	time += delta
#
#	if time >= 2*PI:
#		time -= 2*PI
	
	if shader_material:
		shader_material.set_shader_param("time", time * timefactor)

	if Engine.editor_hint: return
	
	var boat = null
	var camera = get_viewport().get_camera()
	var pivot = camera.get_parent()
	if pivot.has_method("get_boat"):
		#print("water manager: pivot has boat")
		boat = pivot.get_boat()
		
	if not boat: return
	var pos = boat.global_transform.origin
	var dist  = 0.0
	
	if island_manager:
		dist = island_manager.get_closest_distance_to(pos)
		
	#print(dist)
	var max_wave:float = 250
	var min_wave:float = 100
	var max_amplitude = 0.8
	var min_amplitude = 0.2
	
	var normalized_distance = (dist - min_wave) / (max_wave - min_wave)
	var clamp_distance = clamp(normalized_distance, 0.0, 1.0 )
	var result_amplitude = clamp_distance \
		* (max_amplitude - min_amplitude) \
		+ min_amplitude
	if dynamic_amplitude:
		set_amplitude(result_amplitude)
	#print(amplitude)
	
	if water_mesh:
		water_mesh.global_transform.basis = Basis()
		water_mesh.global_transform.origin = boat.global_transform.origin
		water_mesh.global_transform.origin.y = 0.0
	
	
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
	
	
	
#	for i in get_child_count():
#		get_child(i).queue_free()
#	create_debug_tangents()

#func set_next_amplitude(new_amplitude:float):
#	#warning_ignore
#	tween.interpolate_property(self,"amplitude", amplitude, new_amplitude, 
#								abs(amplitude - new_amplitude) * 10,Tween.TRANS_CUBIC,
#								Tween.EASE_IN_OUT)
#	#warning_ignore
#	tween.start()
	
#func set_next_frequency(new_frequency:float):
#	tween.interpolate_property(self,"frequency",frequency, new_frequency, 
#								abs(frequency - new_frequency) * 10,Tween.TRANS_CUBIC,
#								Tween.EASE_IN_OUT)
#	tween.start()
	
func set_default_water_params():
	self.amplitude = default_amplitude
	self.frequency = default_frequency
	self.timefactor = default_timefactor
