tool
extends ImmediateGeometry

#export(Array, PackedScene) var item_scenes = []
export(PackedScene) var item_scene
export(float, 0, 1000) var radius_max:float = 10.0 setget set_radius_max
export(float, 0, 1000) var radius_min:float = 1 setget set_radius_min
var item_proto = null

func _ready():
	randomize()
#	for i in item_scenes:
	item_proto = item_scene.instance()
#		if proto.get("item") != null:
#			item_protos[proto.item] = proto
#		else:
#			proto.queue_free()
	if not Engine.is_editor_hint():
		#for item in item_protos:
		for i in 10: call_deferred("spawn")
		print("spawen barel")

func set_radius_max(val):
	radius_max = val
	draw_area()

func set_radius_min(val):
	radius_min = val
	draw_area()
	
func draw_area():
	clear()
	draw_circle(radius_max, Color.red)
	draw_circle(radius_min, Color.green)
	
func draw_circle(r, color):
	#print("drawing")
	var p_count = 32
	var angle = (PI*2)/p_count
	var cur_angle = 0

	begin(Mesh.PRIMITIVE_LINE_LOOP)
	set_color(color)
	for i in p_count:
		var x = cos(cur_angle)*r
		var y = sin(cur_angle)*r
		#print("x: ",x,"y: ", y)
		add_vertex(Vector3(x,0,y))
		cur_angle += angle
	end()

func spawn():
	var pos = global_transform.origin
	var new_radius = rand_range(radius_min,radius_max)
	var angle = rand_range(0.0, 2*PI)
	var offset = Vector3(cos(angle)*new_radius,0,sin(angle)*new_radius)
	
	
	var new_item = item_proto.duplicate()
	print("created:", (offset), " ",new_item.get_name())
	#get_tree().get_root().add_child(new_item)
	add_child(new_item)
	new_item.global_transform.origin = pos+offset
	
	
	
