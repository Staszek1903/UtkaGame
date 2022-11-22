#tool
extends Spatial

var items = []
export(float) var offset = 0.5
export(bool) var add = false setget set_add
export(bool) var remove = false setget set_remove

func _ready():
	pass

func push_item(node:RigidBody):
	node.mode = RigidBody.MODE_KINEMATIC
	node.get_node("CollisionShape").disabled = true
	node.get_node("Floater").apply_gravity = false
	var parent = node.get_parent()
	if parent:
		parent.remove_child(node)
	items.append(node)
	add_child(node)
	update_positions()



func pop_item() -> RigidBody:
	var node = items.pop_back()
	if not node: return null
	node.mode = RigidBody.MODE_RIGID
	node.get_node("CollisionShape").disabled = false
	node.get_node("Floater").apply_gravity = true
	remove_child(node)
	update_positions()
	return node
	
func update_positions():
	for i in items.size():
		items[i].transform.origin = get_position(i)
		items[i].transform.basis = Basis()
		
func get_position(index:int) ->Vector3:
	var x_pos:int = 0
	var size:int = items.size()
	var height = 1
	while(index >= height):
		index -= height
		height += 1
		x_pos += 1

	return Vector3(x_pos * offset - index * offset * 0.5, index * offset, 0.0)

func set_add(val):
	add = false
	var barrel_scene:PackedScene = load("res://objects/Worker.tscn")
	push_item(barrel_scene.instance())
	
func set_remove(val):
	remove = false
	var node = pop_item()
	if node:
		node.queue_free()
