extends ImmediateGeometry

export(float) var y_height:float = 1.0
export(float) var points_dist:float = 15.0
export(int) var max_point_count:int = 200
export(float) var path_witdh = 10.0
export(Color) var ind_color:Color = Color.yellow
export(Color) var path_color:Color = Color.chocolate

onready var boat = $"../Boat"
var points = []

func funkcja():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(boat)
	#get_parent().remove_child(self)
	#get_tree().get_root().add_child(self)
	global_transform = Transform()
	add_point()
	

# warning-ignore:unused_argument
func _process(delta):
	var dist = get_cur_dist()
#	print(dist)
	if dist > points_dist : add_point()
	clear()
	draw_indicator()
	draw_points()
	
func get_cur_dist():
	var last = points.back().origin
	var cur = boat.global_transform.origin
	return (last-cur).length()

func get_ind_transform():
	var trans:Transform = Transform()
	trans.origin = boat.global_transform.origin
	trans.origin.y = 0
	var boat_basis = boat.global_transform.basis
	var angle = atan2(boat_basis.z.x, boat_basis.z.z)
	#new_basis = new_basis.scaled(global_transform.basis.get_scale())
	trans.basis = trans.basis.rotated(Vector3.UP,angle)
	return trans

func draw_indicator():
	var trans:Transform = get_ind_transform()
	
	begin(Mesh.PRIMITIVE_TRIANGLES)
	set_color(ind_color)
	var v1 = Vector3(0,y_height, -20)
	var v2 = Vector3(10,y_height, 10)
	var v3 = Vector3(-10,y_height, 10)
	
	add_vertex(trans.xform(v1))
	add_vertex(trans.xform(v2))
	add_vertex(trans.xform(v3))
	end()

func add_point():
	points.append(get_ind_transform())
	if points.size() > max_point_count:
		points.pop_front()
	
func draw_points():
	var v1 = Vector3(path_witdh*0.5,y_height,0)
	var v2 = Vector3(-path_witdh*0.5,y_height,0)
	
	begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	set_color(path_color)
	for p in points:
		add_vertex(p.xform(v1))
		add_vertex(p.xform(v2))
		
	end()
