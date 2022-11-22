extends Spatial

var tile_width = 199

enum Direction{
	E,
	NE,
	N,
	NW,
	W,
	SW,
	S,
	SE
}

var coords = [
	Vector3(1,0,0),
	Vector3(1,0,-1),
	Vector3(0,0,-1),
	Vector3(-1,0,-1),
	Vector3(-1,0,0),
	Vector3(-1,0,1),
	Vector3(0,0,1),
	Vector3(1,0,1),
]

var tiles = [
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
]

var marked_in_sight : = false

func _ready():
	add_to_group("watertile")
	if name == "WaterTile": 
		call_deferred("spawn_tiles_around")
	
func clean_tile():
	if marked_in_sight:
		marked_in_sight = false
	else:
		for direction in Direction:
			direction = Direction[direction]
			if tiles[direction]:
				tiles[direction].tiles[reverse_dir(direction)] = null
		queue_free()
		
func garbage_collection():
	marked_in_sight = true
	for t in tiles:
		t.marked_in_sight = true
		
	get_tree().call_group("watertile", "clean_tile")

func reverse_dir(direction:int) -> int:
	return (direction+4)%8

func _on_Area_area_entered(area):
	var camera = area.get_node("../Camera")
	assert(camera)
	if camera.current: spawn_tiles_around()
	
func spawn_tiles_around():
	for direction in Direction:
		direction = Direction[direction]
		spawn_tile(direction)
	
	ensure_tile_connections()
	garbage_collection()

func spawn_tile(direction_index : int):
	if tiles[direction_index] : 
		print("EXISTS: ", direction_index)
		return
	var new_pos = global_transform.origin + coords[direction_index]*tile_width
	var another:Spatial = duplicate()
	another.name = "DynWater"
	another.transform.origin = new_pos
	another.scale = scale
	get_parent().add_child(another)
	another.tiles[reverse_dir(direction_index)] = self
	tiles[direction_index] = another
	print("created: ", another.name, " scale: ", another.scale);
	
func ensure_tile_connections():
	for direction in Direction:
		direction = Direction[direction]
		var next_direction = (direction+1)%8
		var con_direction = connections_direction(direction)
		var revcon_direction = reverse_dir(con_direction)
		connect_tiles(tiles[direction], tiles[next_direction], con_direction)

	connect_tiles(tiles[Direction.E], tiles[Direction.N], Direction.NW)
	connect_tiles(tiles[Direction.N], tiles[Direction.W], Direction.SW)
	connect_tiles(tiles[Direction.W], tiles[Direction.S], Direction.SE)
	connect_tiles(tiles[Direction.S], tiles[Direction.E], Direction.NE)
	
func connections_direction(direction:int) -> int:
	var d = ((direction+3)%8)/2
	return d * 2

""" connections direction explanation 
	
	f(x)
	S6				x	x			
	W4		x	x					
	N2	x							x
	E0						x	x	
		0	1 	2	3	4	5	6	7
"""

func connect_tiles(tile1, tile2, direction_index:int):
	var rev_dir = reverse_dir(direction_index)
	tile1.tiles[direction_index] = tile2
	tile2.tiles[rev_dir] = tile1
	
func group_reposition(center:Vector2):
	var is_center:bool = true
	for tile in tiles:
		if not tile: is_center = false
		
	if is_center: print("CENTER")
	else: 
		print("not center")
		return
	
	for tile in tiles:
		tile.marked_in_sight = false
	marked_in_sight = true
	
	get_tree().call_group("watertile", "clean_tile")
	
	global_transform.origin.x= center.x
	global_transform.origin.z= center.y
	
	
	
