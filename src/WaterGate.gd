extends Spatial
class_name WaterGate

signal passed_through
signal race_end

export(NodePath) var next_gate:NodePath
export(bool) var active:bool = false setget set_active

onready var next_gate_node:WaterGate = get_node(next_gate)
onready var time_counter = $"/root/RaceTimer"

func _ready():
	assert(time_counter)
	set_active(active)
	
func set_active(val:bool):
	active = val
	$LeftBuoy/Indicator.visible = val
	$RightBuoy/Indicator.visible = val

# warning-ignore:unused_argument
func _on_Area_body_entered(body):
	if active:
		#emit_signal("task_finished", "race_finished", time_counter.time_counter)
		emit_signal("passed_through")
		set_active(false)
		if time_counter.is_started == false: #start race
				time_counter.reset_timer()
				time_counter.start_timer()
		if next_gate: 						#proceed to next gate
			next_gate_node.set_active(true)
		elif time_counter:					#end race
			time_counter.stop_timer()
			emit_signal("race_end")
			
			
