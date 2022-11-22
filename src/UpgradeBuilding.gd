extends Spatial

signal upgraded

#export(String) var button_text = "" setget set_button_text

var lock_ui:bool = true
var requirements = []

func _ready():
	set_lock_ui(true)
	for child in get_children():
		if child.is_in_group("item_requirement"):
			requirements.append(child)

func set_lock_ui(val:bool):
	lock_ui = val
	visible = not val
#	if lock_ui:
#		$Button3D.visible = false
#		$IconBaner.visible = false
#	else:
#		update_state()

#func set_button_text(val:String):
#	button_text = val
#	$Button3D.text = val

func update_requirements():
	var parent = get_parent()
	for req in requirements:
		req.available = parent.get_item_count(req.item_name)
		

func _on_Button3D_pressed():
	for req in requirements:
		if not req.satisfied(): return
	for req in requirements:
		get_parent().withdraw_items(req.item_name, req.quantity)
	emit_signal("upgraded")
