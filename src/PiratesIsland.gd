extends Spatial

onready var enemy = $EnemyCutter
onready var enemy_path = $EnemyCutter/Control/ControlPathFolow


func _ready():
	var global_trans = enemy.global_transform
	enemy.get_parent().remove_child(enemy)
	get_tree().get_root().add_child(enemy)
	enemy.global_transform = global_trans
	
	enemy_path.global_transform = global_transform
	enemy_path.current_ind = 0
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(enemy):
			enemy.queue_free()
