extends Resource
class_name TaskResource

export(String) var msg = "Task Msg"
export(NodePath) var node_path = null

var done = false

func initialize_task(task_man:Node):
	var node = task_man.get_node(node_path)
	node.connect("task_finished",self, "_on_task_finished")

func get_string_status():
	return msg + (" DONE" if done else "")

func _on_task_finished(type, time):
	print("task finished in resource: ",type," time: ", time)
	done = true
	emit_signal("changed")
