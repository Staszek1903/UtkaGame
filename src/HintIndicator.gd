extends Spatial
class_name HintIndicator

enum Points{
	NONE,
	HAUL,
	SHEET,
	MOORING,
	POST
}

export(Points) var point

func _ready():
	add_to_group("hint_indicator")
	
func set_hint_visible(point_enum:int, is_visible:bool = true):
	if point_enum == point:
		visible = is_visible

func _on_SteeringPointsCollection_current_changed(_point):
	#print("DUPA ",_point," ", get_parent()," ", visible)
	if visible and _point == get_parent():
		visible = false
		get_tree().call_group("key_hint", "_on_point_satisfied", point)


func _on_DockPoint_mooring_on(boat):
	visible = false
	get_tree().call_group("key_hint", "_on_point_satisfied", point)
