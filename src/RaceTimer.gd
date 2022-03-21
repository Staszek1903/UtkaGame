extends Label

var is_started:bool = false
var time_counter:float = 0.0

func _ready():
	pass # Replace with function body.
	
func start_timer():
	is_started = true
	
func stop_timer():
	is_started = false
	
func reset_timer():
	time_counter = 0.0

func _process(delta):
	if is_started:	time_counter += delta
	text = str(float(int(time_counter*10.0))*0.1)
