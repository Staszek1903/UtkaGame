#tool
extends Spatial

export(PackedScene) var island_map setget set_island_map
export(float) var distance_unit = 10.0
export(float) var spawn_distance:float = 1000.0
export(float) var horizon_distance:float = 500.0

onready var camera = get_viewport().get_camera()


var islands:Array = []
var instances:Dictionary = {}

#var spawn_thread = Thread.new()
#var mutex = Mutex.new()
#var semaphore = Semaphore.new()
#var isl_to_spawn:Array = []
#var isl_to_despawn:Array = []
#var terminate_thread:bool = false

#func _ready():
#	spawn_thread.start(self, "_spawn_thread_process")
#	print("CAMERA: ", camera)
##	call_deferred("set_island_map", island_map)

func _process(_delta):
	call_deferred("update_islands")


#	if not camera:
#		camera = get_viewport()
#		print("CAMERA FOUND" if camera else "CAMERA NOT FOUND")

func set_island_map(_island_map: PackedScene):
	print("set island map")
	if not _island_map: return
	island_map = _island_map
	var _islands = _island_map.instance()
	islands = _islands.get_children()
	
	
	
	
func update_islands():
	#print("update islands")
	if not is_instance_valid(camera) or not camera or not camera.current:
		var v = get_viewport()
		camera = v.get_camera()
		
	if not camera: return

	#var max_dist = 0
	for island in islands:
		var dist = get_distance(island)
		set_island_height(island, dist)
		#if dist > max_dist: max_dist = dist
		if dist < spawn_distance \
		and not instances.has(island):
			print("spawn island")
			call_deferred("spawn_island", island)
		elif dist > spawn_distance\
		and instances.has(island):
			print("despawn island")
			call_deferred("despawn_island", island)

			
	#print(max_dist)

func set_island_height(island, dist):
	if not island in instances: return
	instances[island].transform.origin.y = \
	-get_height_below_horizon(dist)
		
func get_horizon(dist) -> float:
	return clamp((dist - horizon_distance) \
	/ (spawn_distance - horizon_distance), 0.0, 1.0)
	
func get_height_below_horizon(dist) -> float:
	var horizon = get_horizon(dist)
	return horizon * 50.0
	
func get_height_rel_to_camera(pos: Vector3) -> float:
	var dist = get_camera_distance(pos)
	return get_height_below_horizon(dist)

func spawn_island(island:Node2D):
	print("spawning")
	if instances.has(island): return
	print("PROTO: ", island.prototype)
	
	var inst:Spatial = null
	if island.prototype:
		inst = island.prototype.duplicate()
	else:
		inst = island.scene.instance()
#	assert(false)
	instances[island] = inst
	var pos = get_position(island)
	inst.transform.origin = pos
	inst.rotate_y(-island.rotation)
	call_deferred("add_child", inst)

func despawn_island(island:Node2D):
	print("despawning")
	if not instances.has(island): return
	var inst = instances[island]
	var _b = instances.erase(island)
	inst.queue_free()
	
#func _spawn_thread_process(_userdata):
#	print("THREAD STARTED")
#	var island_to_spawn = null
#	var island_to_despawn = null
#	while true:
#		mutex.lock()
#		#print("thread: ", isl_to_spawn.size())
#		island_to_spawn = isl_to_spawn.pop_back()
#		island_to_despawn = isl_to_despawn.pop_back()
#		mutex.unlock()
#
#		if island_to_spawn: spawn_island(island_to_spawn)
#		if island_to_despawn: despawn_island(island_to_despawn)
		
#		if not island_to_despawn and not island_to_spawn:
#			semaphore.wait()

func get_position(island:Node2D) -> Vector3:
	return Vector3(
		island.position.x * distance_unit,
		0.0,
		island.position.y * distance_unit
	)

func get_distance(island:Node2D) -> float:
	var cam_pos: Vector3 = camera.global_transform.origin 
	var isl_pos: Vector3 = get_position(island)
	return cam_pos.distance_to(isl_pos)
	
func get_distance_to(pos: Vector3, island: Node2D) -> float:
	var isl_pos: Vector3 = get_position(island)
	return pos.distance_to(isl_pos)
	
func get_camera_distance(pos: Vector3) -> float:
	if not camera or not is_instance_valid(camera): return 0.0
	var cam_pos: Vector3 = camera.global_transform.origin
	return pos.distance_to(cam_pos)
	
func get_closest_distance_to(pos: Vector3) -> float:
	var min_dist:float = 99999.9
	for island in islands:
		var dist = get_distance_to(pos, island)
		if dist < min_dist: min_dist = dist
		
	return min_dist 
