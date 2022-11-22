extends Spatial
#
#export(String) var port_name:String = "Generic"
#export(Array, PackedScene) var items_accepted
##export(PackedScene) var production_output:PackedScene
#
#
#var dialogic_timeline = "Port"
#var dialogic_node = null
#var production_time:float = 20.0
#const base_production_time:float = 30.0
#var product_count_waiting:float = 0
#var new_product_price:int = 0
#var production_eficiency:float = 2
#
#var worker_scene:PackedScene = preload("res://objects/Worker.tscn")
#
#
#func _init():
##	if not Dialogic.timeline_exists(dialogic_timeline):
##		dialogic_timeline = "Default"
#	make_dialogic_node()
#
#
#func _ready():
#	assert(production_output)
#	if not worker_scene in items_accepted:
#		items_accepted.append(worker_scene)
#
#	$PortCrane.items_accepted = items_accepted
#
#
#onready var work_ind = $WorkInd
#func _process(delta):
#	work_ind.rotate_x(float(product_count_waiting>=1.0) \
#		* $WorkerStack.items.size() \
#		* delta)
#
#
#func make_dialogic_node():
#	dialogic_node = Dialogic.start(dialogic_timeline)
#	dialogic_node.connect("timeline_end", self, "dialog_end")
#	dialogic_node.connect("dialogic_signal", self, "dialogic_signal")
#
#
#func dialog_end(_timeline_name):
#	if is_instance_valid(dialogic_node):
#		dialogic_node.queue_free()
#	make_dialogic_node()
#
#
#func dialogic_signal(val:String):
#	match val:
#		"purchase1":
#			if $OutputItemStack.items.size() >= 1 \
#			and $"/root/CashWallet".cash_amount >= $OutputItemStack.items[0].price:
#				$"/root/CashWallet".cash_amount -= $OutputItemStack.items[0].price
#				$PortItemOutput.spawn_item($OutputItemStack.pop_item())
#		"purchase5":
#			if $OutputItemStack.items.size() >= 5 \
#			and $"/root/CashWallet".cash_amount >= $OutputItemStack.items[0].price * 5:
#				$"/root/CashWallet".cash_amount -= $OutputItemStack.items[0].price * 5
#				for i in 5:
#					$PortItemOutput.spawn_item($OutputItemStack.pop_item())
#
#func _on_Quai_action():
#	Dialogic.set_variable("PortName", port_name)
#	Dialogic.set_variable("WorkerCount", $WorkerStack.items.size())
#	#Dialogic.set_variable("RequiredItem", required_item)
#	#Dialogic.set_variable("Eficiency", production_eficiency)
#	add_child(dialogic_node)
#
#
#func _on_Quai_mooring_off():
#	dialog_end(dialogic_timeline)
#
#
#func _on_PortCrane_cargo_lifted(body):
#	if worker_scene.resource_path == body.filename:
#		$WorkerStack.push_item(body)
#		production_time = base_production_time / float($WorkerStack.items.size())
#	else:
#		$"/root/CashWallet".cash_amount += body.price
#		$InputItemStack.push_item(body)
#
#	production()
#
#var is_producing:bool = false
#func production():
#	if $WorkerStack.items.size() == 0: return
#	if is_producing: return
#
#	if product_count_waiting < 1.0:
#		consume_ingredient()
#
#	if product_count_waiting < 1.0:
#		return
#
#	is_producing = true
#	yield(get_tree().create_timer(production_time), "timeout")
#	is_producing = false
#
#	fabricate_product()
#	production()
#
#func consume_ingredient():
#	if production_eficiency == 0: return
#	while product_count_waiting < 1.0:
#		var node = $InputItemStack.pop_item()
#		if not node: return
#		new_product_price = node.price * 1.5
#		node.queue_free()
#		product_count_waiting += production_eficiency
#
#func fabricate_product():
#	product_count_waiting -= 1.0
#	var node = production_output.instance()
#	node.price = new_product_price
#	$OutputItemStack.push_item(node)
