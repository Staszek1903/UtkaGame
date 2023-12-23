tool
extends MeshInstance

export(bool) var regen_mesh = false setget set_regen_mesh
export(Curve) var water_lod:Curve
export(int) var water_lod_max:float = 50.0

var trail_data_texture:ImageTexture = ImageTexture.new()
var trail_data_image:Image = Image.new()
const trail_dada_size:int = 16 

onready var material = get_surface_material(0)
onready var waterDistortion = $Viewport/WaterDistortion

func set_trail_position(position:Vector3):
	material.set_shader_param("trail_postion", 
		Vector2(-position.x, -position.z))
		
func set_trail_direction(direction:float):
	waterDistortion.direction = direction
	
func set_trail_speed(speed:float):
	waterDistortion.speed = speed
	
func set_trail_radius(radius:float):
	waterDistortion.init_radius = radius
	
func set_trail_segment_length(length:float):
	waterDistortion.segment_length = length
	
func set_front_direction(dir:Vector3):
	var dir_flat = Vector2(-dir.x,dir.z).normalized()
	waterDistortion.front_offset_direction = dir_flat

func set_front_offset(off: float):
	waterDistortion.front_wave_offset = off
	
func set_front_scale(scale:float):
	waterDistortion.front_scale = scale
	
#func set_front_scale_rate(rate:float):
#	waterDistortion.front_scale_rate = rate

func set_regen_mesh(_value:bool):
	print("REGEN WATER MESH")
	generate_mesh()
	
func generate_mesh_circle(st:SurfaceTool, vertices:int, radius:float):
	var angle:float = 0.0
	var vert = Vector3(0,0,0)
	for i in vertices:
		angle = (float(i)/float(vertices)) * 2 * PI
		vert = Vector3(cos(angle),0,sin(angle))
		vert *= radius
		st.add_vertex(vert)

func generate_layer_indices(st:SurfaceTool, layer_begin:int, layer_size:int, prev_layer_begin:int, prev_layer_size:int):
	for i in layer_size:
		#var plv = prev_layer_size * (float(i)/float(layer_size)) 
		var l_coef = layer_size/prev_layer_size
		var plv:int = (i + 1) if l_coef ==  1 else ((i + 1) * 2) if l_coef == 0 else ((i + 2) * 0.5)
		plv %= prev_layer_size

		plv += prev_layer_begin
		st.add_index(plv)
		st.add_index(layer_begin + i)
		st.add_index(layer_begin + (i+1)%layer_size)
	
	if prev_layer_size > 2:
		for i in prev_layer_size:
			var lv = layer_size * ((float((i)%prev_layer_size))/float(prev_layer_size))
			lv += layer_begin
			st.add_index(prev_layer_begin + i)
			st.add_index(lv)
			st.add_index(prev_layer_begin + (i+1)%prev_layer_size)
		
func _ready():
	water_lod.bake()
	generate_mesh()
	
func generate_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_vertex(Vector3(0,0,0))
	var prev_layer_size = 1
	var prev_layer_begin = 0
	var layer_size = 4
	var layer_begin = 1
	var prev_radius = 0
	var radius = 0.1
	var dr = 0.1
	
	#print("LOD POINTS: ", water_lod.get_point_count())
	for i in 200:
		generate_mesh_circle(st, layer_size, radius)
		generate_layer_indices(st, layer_begin, layer_size, prev_layer_begin, prev_layer_size)
		prev_layer_begin = layer_begin
		prev_layer_size = layer_size
		layer_begin = layer_begin + layer_size
		if((2.0*PI*radius)/float(layer_size) > dr*1.5): layer_size *= 2
		if((2.0*PI*radius)/float(layer_size) < dr*0.5): layer_size /= 2
		prev_radius = radius
		radius += dr
		dr = water_lod.interpolate_baked(radius / float(water_lod_max))
		print("radius: ", radius / float(water_lod_max), " lod: ", dr)
	
	
	mesh = st.commit()
	



