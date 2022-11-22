extends Spatial

signal cargo_lifted(body)

var items_accepted = []

onready var tween = $Tween
onready var crane_arm = $CraneArm

var cargo_in_area:Array = []


func is_item_accepted(item:Node) -> bool:
	if items_accepted.size() == 0: 
		return true
	#print("checking item ", item, " of file ", item.filename)
	var acc:bool = false
	for scene in items_accepted:
		#print("checking scene ", scene, " of file ", scene.resource_path)
		acc = acc or (item.filename == scene.resource_path)
	return acc


func _on_Area_body_entered(body):
	if body.get("item") != null:
		if not $Area.overlaps_body(body): return
		if not is_item_accepted(body): return
		cargo_in_area.append(body)
		print("cargo in crane: ", body)
		get_cargo()


func _on_Area_body_exited(body):
	if body in cargo_in_area:
		cargo_in_area.erase(body)


func set_crane_rotation(val:float):
	crane_arm.global_transform.basis = Basis(Vector3.UP, -val)


func get_crane_rotation()->float:
	return -crane_arm.global_transform.basis.get_euler().y


func get_cargo():
	if tween.is_active(): return
	var cargo:RigidBody = cargo_in_area.pop_back()
	if cargo:
		if not $Area.overlaps_body(cargo): 
			get_cargo()
			return
		var vect = cargo.global_transform.origin - crane_arm.global_transform.origin
		var angle:float =  atan2(vect.z, vect.x)
		#var cur_ang = crane_arm.global_transform.basis.get_euler().y
		print("next crane angle: ", angle)
		tween.interpolate_method(self, "set_crane_rotation", get_crane_rotation(),
		angle, 2.0,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
#		tween.interpolate_property(crane_arm, "rotation:y",
#		crane_arm.rotation.y, -angle, 2.0, Tween.TRANS_QUAD)
		tween.start()
		
		yield(tween, "tween_all_completed")
		if not $Area.overlaps_body(cargo):
			get_cargo()
			return
		
		tween.interpolate_property(cargo, "global_transform:origin:y",
		cargo.global_transform.origin.y, cargo.global_transform.origin.y+4,
		1.0,Tween.TRANS_QUAD)
		tween.start()
		
		yield(tween, "tween_all_completed")
		if not $Area.overlaps_body(cargo):
			get_cargo()
			return
		
		cargo.get_parent().remove_child(cargo)
		print("cargo lifted: ", cargo)
		emit_signal("cargo_lifted", cargo)
		get_cargo()
