extends ImmediateGeometry

export(int) var nodes_size:int = 8 setget set_nodes_size
export(float) var segment_size = 0.2
export(float) var begin_width  = 0.4
export(float) var end_width = 0.1
export(float) var gravity = 1.0

onready var last_postion:Vector3 = global_transform.origin
onready var boat_body = get_parent()
onready var wind_manager = $"/root/WindManager"

var nodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_nodes_size(nodes_size)
		
func set_nodes_size(value:int):
	nodes_size = value
	nodes.clear()
	for i in nodes_size:
		nodes.append(Vector3(0,0,0))

func _process(delta):
	assert(boat_body)
	assert(wind_manager)
	var position = global_transform.origin
	var displacement = position - last_postion 
	var wind:Vector3 = wind_manager.global_wind_vector * wind_manager.wind_speed
	global_transform.basis = Basis()
	for i in nodes_size:
		if i == 0 : continue
		nodes[i] -= displacement
		nodes[i] += Vector3(0,-gravity,0) * delta
		nodes[i] += wind * delta
	rope_algorithm()
	draw_flag()
	
	last_postion = position
	
	
func rope_algorithm():
	for i in nodes_size:
		if i == 0 : continue
		var diff = nodes[i] - nodes[i-1]
		var dist = diff.length()
		if dist > segment_size:
			nodes[i] = nodes[i-1] + diff.normalized() * segment_size

func draw_flag():
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var up = boat_body.global_transform.basis.y
	for i in nodes_size:
		var width = begin_width + (end_width-begin_width) * (float(i)/float(nodes_size))
		var normal:Vector3 = Vector3(1,0,0)
		if i < nodes_size -1:
			normal = (nodes[i] - nodes[i+1]).cross(up).normalized()
		else:
			normal = (nodes[i-1] - nodes[i]).cross(up).normalized()
			
		set_normal(normal)
		add_vertex(nodes[i] + up * width * 0.5)
		set_normal(normal)
		add_vertex(nodes[i] - up * width * 0.5)
	end()
		
