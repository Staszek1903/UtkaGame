extends Spatial

onready var anim: AnimationPlayer = $AnimationPlayer
onready var gui = $Control
onready var utka:RigidBody = get_parent()
onready var thrust_pos = $ThrustPos
onready var fuel_ind = $FuelIndicator
onready var particles = $Particles

const power:float = 4.0
const fuel_ammount = 600

var is_on:bool = false
var is_transitioning:bool = false
var current_gear = "N"
var thrust:int = 0


func _ready():
	fuel_ind.value = 1.0
	anim.play_backwards("to_water")

func _physics_process(delta):
	if !is_on or current_gear == "N": return
	var rel_pos = thrust_pos.global_transform.origin - \
	utka.global_transform.origin
	var forward= -utka.global_transform.basis.z
	if current_gear == "R": forward *= -1
	utka.add_force(forward*thrust*power*delta,rel_pos)
	fuel_ind.value -= (delta*thrust)/fuel_ammount
	if fuel_ind.value == 0 :
		is_on = false
		gui.set_state("OFF")
	

func _input(event):
	if event is InputEventKey and event.pressed:
		match(event.scancode):
			KEY_E:
				if is_transitioning : return
				if not is_on and current_gear != "N": return
				is_transitioning = true
				if is_on: anim.play_backwards("to_water")
				else: anim.play("to_water")
				yield(anim, "animation_finished")
				is_transitioning = false
				is_on = !is_on
				if is_on: gui.set_state("ON")
				else: gui.set_state("OFF")
			KEY_R:
				if current_gear == "N" : current_gear = "F"
				else: current_gear = "N"
				gui.set_gear(current_gear)
			KEY_F:
				if current_gear == "N" : current_gear = "R"
				else: current_gear = "N"
				gui.set_gear(current_gear)
			KEY_T:
				if thrust < 4 : thrust += 1
				gui.set_power(str(thrust))
			KEY_G:
				if thrust > 0 : thrust -= 1
				gui.set_power(str(thrust))
				
		particles.emitting = is_on and current_gear == "F" and thrust>0
