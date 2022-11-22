extends Spatial

onready var pos = $SpawnPos

func spawn_item(node:RigidBody):
	
	if not node: return
	get_tree().get_root().add_child(node)
	node.global_transform = pos.global_transform
