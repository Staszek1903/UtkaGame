tool
extends Node2D

export(float) var direction = 0.0
export(float) var speed = 100.0
export(float) var front_alpha = 1.0
export(float) var disapearing = 0.1
export(float) var cone = 0.1
export(float) var init_radius = 25.0
export(int) var trail_size = 20 setget set_trail_size
export(float) var segment_length = 30.0
export(float) var segment_lifetime = 10.0

export(float) var front_wave_offset = 50.0 setget set_front_wave_offset
export(Vector2) var front_offset_direction:Vector2 = Vector2(1,0)
export(float) var front_scale = 0.1 setget set_front_scale
export(float) var front_scale_rate = 0.1 setget set_front_scale_rate


onready var polygon:Polygon2D = $Polygon2D
onready var boat_hole = $Polygon2D/BoatHole
onready var front_wave:Particles2D = $Particles2D

var trail:PoolVector2Array = PoolVector2Array()
var life_time:PoolRealArray = PoolRealArray()

func _ready():
	boat_hole.color = Color(1,0,2)
	front_wave.emitting = false
	front_wave.restart()
	front_wave.emitting = true

	set_trail_size(trail_size)
	set_front_scale(front_scale)
	set_front_scale_rate(front_scale_rate)
	set_generate_wave_image()
	process_trail_image()
#	var a = Vector2.ZERO
#	for i in trail_size:
#		trail.append(a)
#		a += Vector2(1,0).rotated(direction) * 10.0
#
#	var p = []
#	p.resize(trail_size * 2)
#	polygon.polygon = PoolVector2Array(p)
#	make_trail_polygon()

func set_front_wave_offset(value:float):
	front_wave_offset = value
	set_front_wave_position()
	
func set_front_scale(value:float):
	front_scale = value
	if not front_wave: return
	#print(front_wave.material)
	front_wave.process_material.set_shader_param("scale", value)
	front_wave.process_material.set_shader_param("scale_rate", (front_scale_rate * 0.1) / front_scale)
	
	
func set_front_scale_rate(value:float):
	front_scale_rate = value
	if not front_wave: return
	front_wave.process_material.set_shader_param("scale_rate", (value * 0.1) / front_scale)
	
func set_trail_size(var value):
	trail.resize(value)
	life_time.resize(value)
	trail_size = value
	
	var p = []
	p.resize(trail_size * 2)
	if(polygon):
		polygon.polygon = PoolVector2Array(p)
		polygon.vertex_colors = PoolColorArray(p)
		polygon.uv = PoolVector2Array(p)
		
		for i in trail_size*2:
			polygon.vertex_colors[i] = Color(1,1,1,front_alpha)
	
	var indices = []
	for i in trail_size:
		indices.append([i,
			trail_size*2 - 1 - i,
			trail_size*2 - 2 - i ])
		
		indices.append([i,
			trail_size*2 - 2 - i,
			i + 1 ])
	
	polygon.polygons = indices
	
	var l = 0.0
	for i in trail_size:
		polygon.uv[i] = Vector2(l,0)
		polygon.uv[trail_size*2 - 1 -i] = Vector2(l, 256)
		l += segment_length
#		l = fmod(l,512.0)

func _process(delta):
	var normal = Vector2(1,0).rotated(direction)
	for i in trail_size:
		if i == 0: continue
		trail[i] += normal * speed * delta
		life_time[i] += delta
		polygon.vertex_colors[i].a = \
			clamp(polygon.vertex_colors[i].a - delta * disapearing, 0,1)
		polygon.vertex_colors[trail_size*2 - i].a = \
			clamp(polygon.vertex_colors[trail_size*2 - i].a - delta * disapearing, 0, 1)
		
	if trail[0].distance_to(trail[1]) > segment_length:
		for i in trail_size:
			if i == trail_size-1: continue
			polygon.uv[trail_size-i-1] = polygon.uv[trail_size-i-2]
			polygon.uv[trail_size + i ] = polygon.uv[trail_size + i +1]
		polygon.uv[0] += Vector2(segment_length,0)
		polygon.uv[trail_size*2 -1] += Vector2(segment_length,0)
		
		for i in trail_size:
			if i == trail_size-1: continue
			polygon.vertex_colors[trail_size-i-1] = polygon.vertex_colors[trail_size-i-2]
			polygon.vertex_colors[trail_size + i ] = polygon.vertex_colors[trail_size + i +1]
		polygon.vertex_colors[0].a = front_alpha
		polygon.vertex_colors[trail_size*2 -1].a = front_alpha
			
		for i in trail_size:
			if i == trail_size-1: continue
			trail[trail_size-i-1] = trail[trail_size-i-2]
			life_time[trail_size-i-1] = life_time[trail_size-i-2]
		trail[0] = Vector2.ZERO
		trail[1] = Vector2.ZERO + normal * 0.01
		life_time[0] = 0
		life_time[1] = 0
		
		
	
	make_trail_polygon()
	set_front_wave_position()
	#print(speed)
	var alpha = clamp(speed/200.0, 0, 1)
	var color_value = Color(1,1,1,0.2 * alpha)
	front_wave.process_material.set_shader_param("direction", Vector3(normal.x, normal.y, 0))
	front_wave.process_material.set_shader_param("initial_linear_velocity", speed * (15.0/100.0))
	front_wave.process_material.set_shader_param("color_value", color_value)
	front_alpha = alpha

func set_front_wave_position():
	if not polygon : return
	var pos = polygon.position + (front_offset_direction * front_wave_offset) 
	front_wave.position = pos
	var d = front_offset_direction
	boat_hole.transform.y = Vector2(-d.y, d.x).normalized()
	boat_hole.transform.x = d.normalized()
	
func tangent(var vect:Vector2) -> Vector2:
	return Vector2(-vect.y, vect.x)

func make_trail_polygon():
	var normal = Vector2(1,0).rotated(direction)
	var tangent = tangent(normal)
	var thicc = init_radius
	
	var length = 0.0
	var first_segment = trail[0].distance_to(trail[1])
	var last_segment = segment_length - first_segment
	var full_length = segment_length * (trail_size-2)
	for i in trail_size:
		thicc = init_radius + life_time[i] * cone
		var color = Color(1,1,1,1.0 - clamp(life_time[i]/segment_lifetime, 0, 1))
		polygon.polygon[i] = trail[i] + tangent * thicc
		polygon.polygon[trail_size*2-1-i] = trail[i] - tangent * thicc
		thicc += 2.0
		var next = trail[i+1] if i+1 < trail_size else Vector2.ZERO
		normal = (next - trail[i]).normalized()
		tangent = tangent(normal)
		
		length = first_segment + i*segment_length
		if i == trail_size-2:
			length = first_segment + (i-1)*segment_length +last_segment
			
var wave_image
var wave_texture:ImageTexture
export(Vector2) var wave_image_size = Vector2(512, 512)
export(bool) var generate_wave_image = false setget set_generate_wave_image

export(float) var start_wave = 0.5 setget set_start_wave
export(float) var end_wave = 1.0 setget set_end_wave

func set_start_wave(value:float):
	start_wave = value
	set_generate_wave_image()
	
func set_end_wave(value:float):
	end_wave = value
	set_generate_wave_image()

func set_generate_wave_image(value = true):
	generate_wave_image = value
	wave_image = Image.new()
	wave_image.create(wave_image_size.x, wave_image_size.y, false, Image.FORMAT_RGBAF)
	wave_image.lock()
	var center = wave_image_size/2.0
	for x in wave_image_size.x:
		for y in wave_image_size.y:
			var coords = Vector2(x/wave_image_size.x,y/wave_image_size.y) * 2.0
			var dist = (coords - Vector2(1,1)).length()
			dist = (clamp(dist, start_wave, end_wave) - start_wave) / (end_wave - start_wave)
			var wave = sin(dist * PI)
			wave_image.set_pixel(x,y, Color(1,1,0,wave))
	generate_wave_image = false
	wave_image.unlock()
	
	wave_texture = ImageTexture.new()
	wave_texture.create_from_image(wave_image)
	
	call_deferred("set_particle_texture")
	print("WAVE IMAGE GENERATED")
	

func set_particle_texture():
	$Particles2D.texture = wave_texture
	
func process_trail_image():
	var texture = ImageTexture.new()
	var image:Image = Image.new()
	image.load("res://assets/ripple.png")
	image.lock()
	var size = image.get_size()
	for x in size.x:
		for y in size.y:
			var p = image.get_pixel(x,y)
			var depth = sin((float(y)/float(size.y)) * PI)
			image.set_pixel(x,y,Color(p.r*p.a,0,depth,1))
	image.unlock()
	texture.create_from_image(image)
	$Polygon2D.texture = texture
