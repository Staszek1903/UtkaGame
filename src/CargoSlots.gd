extends Spatial

var slots = []
var sp:int = 0

func _ready():
	for i in 5:
		var node = get_node("Position3D" + str(i+1))
		slots.append(node)

func add_item(node:RigidBody):
	if not node: return
	if sp >= slots.size() : return
	var parent = node.get_parent()
	if parent:
		parent.remove_child(node)
	node.mode = RigidBody.MODE_KINEMATIC
	node.get_node("Floater").apply_gravity = false
	node.get_node("CollisionShape").disabled = true
	slots[sp].add_child(node)
	node.transform = Transform()
	sp = sp + 1

func remove_item() -> Node:
	if sp == 0 : return null
	sp = sp - 1
	var node:RigidBody = slots[sp].get_child(0)
	slots[sp].remove_child(node)
	node.mode = RigidBody.MODE_RIGID
	node.get_node("Floater").apply_gravity = true
	node.get_node("CollisionShape").disabled = false
	return node
