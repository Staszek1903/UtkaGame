extends Spatial

signal upgraded

#export(String) var button_text = "" setget set_button_text

var lock_ui:bool = true setget set_lock_ui
var requirements = []

func _ready():
	set_lock_ui(true)
	for child in get_children():
		if child.is_in_group("item_requirement"):
			requirements.append(child)
			
	set_lock_ui(lock_ui)

func set_lock_ui(val:bool):
	lock_ui = val

	$Button3D.visible = not val
	for req in requirements:
		req.visible = not val

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
