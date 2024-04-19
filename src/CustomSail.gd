tool
extends ImmediateGeometry


enum  PrimitiveType {
	POINTS = 0,
	LINES = 1,
	LINE_STRIP = 2,
	LINE_LOOP = 3,
	TRIANGLES = 4,
	TRIANGLE_STRIP = 5,
	TRIANGLE_FAN = 6
}

export(bool) var regen_mesh = false setget set_regen_mesh
export(NodePath) var head_path
export(NodePath) var tack_path
export(NodePath) var clew_path
export(NodePath) var peak_path

export(int) var h_subs = 1
export(int) var v_subs = 1

export(Vector3) var force:Vector3

export(PrimitiveType) var primitive = 5

var head:Position3D
var tack:Position3D
var clew:Position3D
var peak:Position3D

var h:Vector3
var p:Vector3
var t:Vector3
var c:Vector3

var rest_verts:Array
var v_lens:Array
var verts:Array = []
var normals:Array = []

func _ready():
	head = get_node(head_path)
	tack = get_node(tack_path)
	clew = get_node(clew_path)
	peak = get_node(peak_path)
	assert(head)
	assert(tack)
	assert(clew)
	assert(peak)
	h = to_local(head.global_transform.origin)
	p = to_local(peak.global_transform.origin)
	t = to_local(tack.global_transform.origin)
	c = to_local(clew.global_transform.origin)

	generate_square_verts()
	#rest_verts = verts.duplicate(true)
	
	print("READY DONE")
	
func set_regen_mesh(val):
	generate_square_verts()

func _process(delta):
	h = to_local(head.global_transform.origin)
	p = to_local(peak.global_transform.origin)
	t = to_local(tack.global_transform.origin)
	c = to_local(clew.global_transform.origin)
#	if Engine.editor_hint: generate_verts()
	sail_phsx(delta)
	calculate_normals()
	generate_mesh()
	
func generate_square_verts():
	verts.clear()
	normals.clear()
	v_lens.clear()
	for u in v_subs+2:
		verts.append([])
		normals.append([])
		for v in h_subs+2:
			var vect = vert_from_uv(u,v)
			verts[u].append(vect)
			normals[u].append(Vector3())
	
	for x in verts.size():
		v_lens.append([])
		for y in verts[x].size()-1:
			v_lens[x].append(verts[x][y].distance_to(verts[x][y+1]))
		v_lens[x].append(v_lens[x][v_lens[x].size()-1])
	
	print("SAIL VERTS GENERATED")

func calculate_normals():
	var xp:int = 0 # x prev
	var yp:int = 0 # y prev
	var xn:int = 0 # x next
	var yn:int = 0 # y next
	var y_xn:int = 0 # y for next_x
	var x_vect:Vector3
	var y_vect:Vector3
	for x in normals.size():
		xp = clamp(x-1, 0, normals.size()-1)
		xn = clamp(x+1, 0, normals.size()-1)
		for y in normals[x].size():
			yp = clamp(y-1, 0, normals[x].size()-1)
			yn = clamp(y+1, 0, normals[x].size()-1)
			y_xn = clamp(y, 0, normals[xn].size()-1)
			x_vect = verts[xn][y_xn] - verts[xp][y]
			y_vect = verts[x][yn] - verts[x][yp]
			normals[x][y] = y_vect.cross(x_vect).normalized()

func vert_from_uv(u:int, v:int) -> Vector3:
	var vect:Vector3
	var hp = (p - h) / (v_subs+1)
	var ht = (t - h) / (h_subs+1)
	var pc = (c - p) / (h_subs+1)
	var vv = ht + (pc-ht) / (v_subs+1) * u
	vect = h + hp * u + vv * v
	return vect
	
func generate_mesh():
	clear()
	var normal:Vector3
	var dx:Vector3
	var dy:Vector3
	var y_xn = 0
	for x in verts.size()-1:
		begin(primitive)
		for y in verts[x].size():
			y_xn = clamp(y, 0, verts[x+1].size()-1)
			set_normal(normals[x][y])
			set_uv(Vector2(float(x)/v_subs,float(y)/h_subs))
			add_vertex(verts[x][y])
			set_normal(normals[x][y])
			set_uv(Vector2(float(x+1)/v_subs,float(y_xn)/h_subs))
			add_vertex(verts[x+1][y_xn])
		end()

func sail_phsx(delta):
	apply_global_force(delta)
	update_static_verts()
	rope_square_algorithm()

		
	
func update_static_verts():
	for x in verts.size():
		verts[x][0] = h + ((p-h) / (verts.size()-1)) * x
		
	for x in verts.size():
		verts[x][h_subs+1] = t + ((c-t) / (verts.size()-1)) * x
		

func rope_square_algorithm():
	for x in verts.size():
		#var xclamp = clamp(x,0, v_lens.size()-1)
		for y in verts[x].size()-2:
			#var yclamp = clamp(y,0, v_lens[xclamp].size()-1)
			var distvsq = verts[x][y].distance_squared_to(verts[x][y+1])
			if distvsq > v_lens[x][y] * v_lens[x][y]:
				verts[x][y+1] = verts[x][y] + \
				(verts[x][y+1] - verts[x][y]).normalized() * v_lens[x][y]
	
	for x in verts.size():
		for ym in verts[x].size()-2:
			var y = h_subs-ym+1
			var yp = h_subs-ym
			var yclamp = clamp(y,0, v_lens[x].size()-1)
			var distvsq = verts[x][y].distance_squared_to(verts[x][yp])
			if distvsq > v_lens[x][yclamp] * v_lens[x][yclamp]:
				verts[x][yp] = verts[x][y] + \
				(verts[x][yp] - verts[x][y]).normalized() * v_lens[x][yclamp]

func apply_global_force(delta):
	for x in verts.size():
		for y in verts[x].size():
			verts[x][y] += force*delta
