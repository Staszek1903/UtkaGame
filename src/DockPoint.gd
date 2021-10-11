extends Position3D

var present_node:Node = null
var docked_end:Node = null
var docked_end_rest_pos:Transform
var docked_rope:Spatial = null

func _process(delta):
	if docked_end:
		docked_end.global_transform = global_transform
		docked_rope.apply_force(delta*20)

func _on_Area_area_entered(area):
	if present_node: return
	print("mooring entered")
	$Indicator.visible = true
	present_node = area
	
func _on_Area_area_exited(area):
	if present_node == area:
		present_node = null
		$Indicator.visible = false

func _input(event):
	if event is InputEventKey \
	and event.pressed \
	and event.scancode == KEY_H:
		if docked_end:
			$Tween.interpolate_property(docked_end,"transform",
			 docked_end.transform, docked_end_rest_pos, 
			1,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
			$Tween.start()
			#docked_end.tra = docked_end_rest_pos
			docked_end = null
		elif present_node:
			var cur_pressent = present_node
			var mooring_end = cur_pressent.get_parent().get_mooring_end(present_node)
			var rope = cur_pressent.get_parent().get_mooring_rope(present_node)
			var rest_pos = mooring_end.transform
			$Tween.interpolate_property(mooring_end,"global_transform",
			 mooring_end.global_transform, global_transform, 
			2,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
			$Tween.start()
			yield($Tween,"tween_all_completed")
			docked_end = mooring_end
			docked_end_rest_pos = rest_pos
			docked_rope = rope
			print("dock_complete")
			
		
