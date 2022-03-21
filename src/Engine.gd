extends Spatial

onready var anim: AnimationPlayer = $AnimationPlayer
onready var utka:RigidBody = get_parent()
onready var thrust_pos = $ThrustPos
onready var fuel_ind = $FuelIndicator
onready var particles = $Particles

var power:float = 500
const fuel_ammount = 600

var is_on:bool = false
var is_transitioning:bool = false
var current_gear = "N"
var previous_gear = "R"
var thrust:float = 0.0


func _ready():
	fuel_ind.value = 1.0
	anim.play_backwards("to_water")

func _physics_process(delta):
	if !is_on or current_gear == "N": return
	var rel_pos = thrust_pos.global_transform.origin - \
	utka.global_transform.origin
	var forward= -utka.global_transform.basis.z
	if current_gear == "R": forward *= -1
	var engine_force = thrust * power * delta
	utka.add_force(forward * engine_force, rel_pos)
	#print(engine_force)
	fuel_ind.value -= (delta*thrust)/fuel_ammount
	if fuel_ind.value == 0 :
		is_on = false
		
func toggle_engine():
	if is_transitioning : return
	#if not is_on and current_gear != "N": return
	is_on = !is_on
	is_transitioning = true
	if is_on: anim.play_backwards("to_water")
	else: anim.play("to_water")
	yield(anim, "animation_finished")
	is_transitioning = false
	
	
func change_gear():
	if previous_gear == "R" : 
		current_gear = "F"
		previous_gear = "N"
	elif previous_gear == "F" :
		current_gear = "R"
		previous_gear = "N"
	else:
		previous_gear = current_gear
		current_gear = "N"


func change_thrust(val):
	thrust += val
	thrust = clamp(thrust, 0.0, 1.0)
	

#	particles.emitting = is_on and current_gear == "F" and thrust>0
