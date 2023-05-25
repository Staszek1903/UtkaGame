tool
extends ImmediateGeometry

export(float, 0, 1000) var radius_max:float = 10.0 setget set_radius_max
export(float, 0, 1000) var radius_min:float = 1 setget set_radius_min
export(int) var item_count = 10
export(Array,String) var item_names = ["Food", "Wood", "Fabric",
	"Steel", "CannonBall"]
export(bool) var spawn_on_ready = true
var item_protos:Array = []
#var item_spawned_count:int = 0
var items_spawned:Array = []

func _ready():
	randomize()
	item_protos.append(preload("res://scenes/objects/Barel.tscn").instance())
	item_protos.append(preload("res://scenes/objects/Crate.tscn").instance())

	if not Engine.is_editor_hint() and spawn_on_ready:
		for i in item_count: call_deferred("spawn")

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

func spawn_all():
	for i in item_count: 
		spawn()

func spawn():
	var pos = global_transform.origin
	var new_radius = rand_range(radius_min,radius_max)
	var angle = rand_range(0.0, 2*PI)
	var offset = Vector3(cos(angle)*new_radius,0,sin(angle)*new_radius)
	var variant = randi() % item_protos.size()
	
	
	var new_item = item_protos[variant].duplicate()
	fill_item(new_item)
	#print("created:", (offset), " ",new_item.get_name(), " ", new_item.items)
	#get_tree().get_root().add_child(new_item)
	get_tree().get_root().get_node("Root").add_child(new_item)
	new_item.global_transform.origin = pos+offset
	items_spawned.append(new_item)
	new_item.connect("freed", self, "_on_item_freed")
	
func fill_item(item:Spatial):
	var count = (randi() % 3) + 1
	#print("count: ", count)
	for i in count:
		var name_i = randi() % item_names.size()
		item.add_item(item_names[name_i], 1)
		
func _on_item_freed(item):
	print("ON FREED")
	items_spawned.erase(item)
	#item_spawned_count -= 1
	var timer = get_tree().create_timer(3)
	timer.connect("timeout",self,"spawn")

func free_items():
	items_spawned = []

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for item in items_spawned:
			if item and is_instance_valid(item): 
				item.queue_free()
	
