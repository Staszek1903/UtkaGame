extends Node

signal race_won

onready var boat:Spatial = $"../Boat"
onready var bom:Spatial = $"../Boat/Bom"
onready var audio = $"../Boat/AudioPlayer"

onready var wind_man = $"/root/WindManager"

export(float) var target_angle = 0.0 setget set_target_angle
export(Resource) onready var pidc = pidc if pidc else PidController.new()
export(bool) var activated = true setget set_activated

var current:bool = false setget set_current
const min_npc_velocity:float = 0.5

func _ready():
	assert(wind_man)

	assert(pidc)
	assert(boat)
	assert(bom)
	add_to_group("steering")
	set_activated(activated)
	
func set_activated(val:bool):
	print("NPC ACTIVE: ", val)
	activated = val
#	if boat:
#		boat.call_deferred("set_sails_active", val)
#	else:
#		call_deferred("set_activated",val)

func set_current(val:bool):
	if val: get_tree().call_group("steering", "clear_current")
	call_deferred("set_this_current")

func clear_current():
	current = false

func set_this_current():
	assert(false, "npc boat cant be chosen as current")
	
func set_target_angle(val:float):
	#print("target_setter1 ",val)
	val = wrapf(val, -PI, PI)
	#print("target_setter2 ",val)
	target_angle = val
	
func _physics_process(_delta):
	update_speed()
	update_rudder()
	update_agr(_delta)
	update_sail()
	
func update_speed():
	var forward_vel = -boat.linear_velocity.dot(
		boat.global_transform.basis.z)
	
	var boat_vect = -boat.global_transform.basis.z
	var boat_angle = atan2(boat_vect.x, boat_vect.z)
	var diff = angle_diff(wind_man.wind_angle, boat_angle)
	diff = clamp(diff / PI, 0.1, 1.0)
	
	var max_speed = wind_man.wind_speed * diff
	#print("MAX: ", max_speed)
	if forward_vel < max_speed and activated:
		boat.add_central_force(-boat.global_transform.basis.z * 100)
		#print("V: ", forward_vel) 

func update_rudder():
	var forward_vel = -boat.linear_velocity.dot(
		boat.global_transform.basis.z)
#	if forward_vel < min_npc_velocity and activated:
#		boat.add_central_force(-boat.global_transform.basis.z)

	var g_rot_y: float = boat.global_transform.basis.get_euler().y
	var error = g_rot_y - target_angle
	error = wrapf(error, -PI, PI)
	
	
	var response = pidc.integrate(error)
	resp = response
	for_vel = forward_vel
	rud = clamp(response, -1.0, 1.0) * clamp(forward_vel,0.0,1.0)
	boat.rudder.set_angle_normalized(rud)

var resp:float = 0.0
var for_vel:float = 0.0
var rud:float = 0.0


var sail_trim:float
#func update_sail_trim():
#	var new_sail_trim = boat.sail_trim
#	var wind_tack = sign(wind_man.global_wind_vector.dot(
#		boat.global_transform.basis.x))
#	var bom_tack = sign(bom.global_transform.basis.z.dot(
#		-boat.global_transform.basis.x))
#	var wind_angle = 180.0 - rad2deg(bom.wind_angle)# 0 ... 180 -> 10
#	#print("S A: ", wind_angle," ",sail_trim, " T: ", wind_tack, " ", bom_tack)
#
#	if wind_tack != bom_tack: 
#		new_sail_trim -= 0.1
#	elif bom.global_force.dot(
#		-boat.global_transform.basis.z) < 0.0:
#		new_sail_trim -= 0.1
#	elif wind_angle < 10.0 :
#		new_sail_trim -= 0.1
#	elif wind_angle > 20.0 :
#		new_sail_trim += 0.1
#
#	sail_trim = clamp(new_sail_trim,
#		15.0 if boat.linear_velocity.length() > min_npc_velocity \
#		else 0.0,
#		90.0)
#	boat.set_sail_trim(sail_trim)

func angle_diff(a:float, b:float) -> float:
	var diff = abs(a-b)
	if diff > PI :
		diff = 2*PI - diff
	return diff

#func _on_BaseQuai_mooring_on():
#	if activated: 
#		self.activated = false
#		emit_signal("race_won")
#		print("RACE WON")
#
#
#func _on_ControlPathFolow_path_finished():
#	if activated:
#		self.activated = false
#		print("RACE LOST")

var player_boat:Spatial = null

onready var ring2 = load("res://souds/ships-bell-ringtone2.mp3")
onready var ring_cont = load("res://souds/ships-bell-ringtone_continous.mp3")

func _on_ArgArea_body_entered(body:Spatial):
	#return
	if body.is_in_group("boat") and body.is_current():
		player_boat = body
		audio.stream = ring2
		audio.play()
		

func _on_ArgArea_body_exited(body):
	#return
	if body == player_boat:
		player_boat = null
		unagr()
		

var is_agr:bool = false

func agr():
	$ControlPathFolow.active = false
	$ControlAgrTargeting.active = true
	is_agr = true
	
func unagr():
	$ControlPathFolow.active = true
	$ControlAgrTargeting.active = false
	is_agr = false

export(float) var agr_time:float = 5.0
var agr_timer:float = 0.0
func update_agr(delta):
	if player_boat and not is_agr:
		if agr_timer > agr_time:
			agr()
			audio.stream = ring_cont
			audio.play()
			yield(get_tree().create_timer(2.9),"timeout")
			audio.stop()
		else:
			agr_timer += delta
			
#		AudioStreamPlayer3D
	
func update_sail():
	var wind_vector:Vector3 = wind_man.global_wind_vector
	var forward_vect:Vector3 = -boat.global_transform.basis.z
	var relative_wind_angle:float = forward_vect.angle_to(-wind_vector)
	var side = sign(forward_vect.cross(wind_vector).y)
	
	relative_wind_angle = clamp(relative_wind_angle, 0.0, PI*0.5)
	#print("to wind ", relative_wind_angle, " ", side)
	
	var sail_rotation = -relative_wind_angle * side * 0.9
	bom.transform.basis = Basis(Vector3.UP, sail_rotation)
