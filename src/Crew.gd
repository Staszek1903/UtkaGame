extends Spatial

export(int,0,100) var max_count:int = 5
onready var spawn_point = $CrewSpawn
var crewmate_scene = preload("res://scenes/Crewmate.tscn")

var crew = []

func spawn():
	if crew.size() < max_count:
		var new_crewmate = crewmate_scene.instance()
		add_child(new_crewmate)
		new_crewmate.transform.origin = spawn_point.transform.origin
		crew.append(new_crewmate)

func _on_SteeringPointsCollection_current_changed(point):
	if not point: return
	if not point.is_man_required: return
	
	var closest_d = 99999.0
	var closest_c = null
	for c in crew:
		var d = \
			c.transform.origin.distance_to(point.transform.origin)
		if d < closest_d:
			closest_d = d
			closest_c = c
			
	if not closest_c: return
	closest_c.assigned_point = point
