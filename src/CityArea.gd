extends Spatial

var dialogic_node = null
var dialogic_timeline = "MainCity"
#var worker_scene = preload("res://objects/Worker.tscn")
var workers_available:int = 2

var cargo_sold:Dictionary = {}
var cash_spent:int = 0
const worker_price:int = 1000

func _ready():
	make_dialogic_node()

func _on_PortCrane_cargo_lifted(body:Node):
#	if body.filename == worker_scene.resource_path:
#		$PortItemOutput.spawn_item(body)
#		return
#	var cash:int = body.price * 2
#	log_cargo(body.filename, cash)
#	log_cash(cash)
#	$"/root/CashWallet".cash_amount += cash
#	body.queue_free()
	pass

func log_cargo(name:String, cash:int):
	if name in cargo_sold:
		cargo_sold[name] += cash
	else:
		cargo_sold[name] = cash
		
func log_cash(cash:int):
	cash_spent += cash
	var new_workers:int = cash_spent / worker_price
	cash_spent -= new_workers * worker_price
	workers_available += new_workers

func _on_DockPoint3_action():
	Dialogic.set_variable("WorkersAvailable", workers_available)
	add_child(dialogic_node)


func make_dialogic_node():
	dialogic_node = Dialogic.start(dialogic_timeline)
	dialogic_node.connect("timeline_end", self, "dialog_end")
	dialogic_node.connect("dialogic_signal", self, "dialogic_signal")


func dialog_end(_timeline_name):
	if is_instance_valid(dialogic_node):
		dialogic_node.queue_free()
	make_dialogic_node()


func dialogic_signal(val:String):
	match val:
		"hire":
			if workers_available > 0:
				workers_available -= 1
				#$PortItemOutput.spawn_item(worker_scene.instance())
				Dialogic.set_variable("WorkersAvailable", workers_available)
