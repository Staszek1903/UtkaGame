extends Position3D

onready var waterManager = $"/root/Root/WaterManager"
onready var islandManager = $"/root/Root/IslandsManager"
onready var body: RigidBody =$"../"
# POZOR: system gravity used as wind force for sails simulation
#onready var gravity_magnitude : float = ProjectSettings.get_setting("physics/3d/default_gravity")
#onready var gravity_vector  = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
export(bool) var enabled = true
export(float,0.001,100) var depthBeforeSubmerged = 0.5
export(float) var impulseMultipier = 100.0
export(bool) var apply_gravity = false
#export(int) var floatersCount = 1

var gravity_magnitude : float = 9.8
onready var gravity_vector = Vector3(0,-1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	assert(waterManager)
	assert(islandManager)
	#print(gravity_magnitude)
	#body.linear_damp = 0.9
	#body.angular_damp = 1


func _physics_process(delta):
	if not enabled: return
	
	var global_offset = to_global(Vector3()) - body.to_global(Vector3())
	
	#body.apply_impulse(translation,
	#delta * Vector3(0, -gravity_magnitude / floatersCount, 0))
	#body.add_force(Vector3(0, delta * -gravity_magnitude * body.mass / , 0), 
	#to_global(Vector3() - body.to_global(Vector3())))
	
	var global_pos = to_global(Vector3.ZERO)
	var h = global_pos.y
	var wave_h = 0.0
	#if is_instance_valid(waterManager):
	if waterManager:
		wave_h = waterManager.wave(Vector2(global_pos.x, global_pos.z))
	else:
		wave_h = 0.0

	h = h - wave_h + islandManager.get_height_rel_to_camera(global_pos)
	
	if h < 0.0 :
		var submerged = clamp( -h /depthBeforeSubmerged, 0,1)
		var impulse =  submerged\
		* impulseMultipier \
		* gravity_magnitude \
		* body.mass \
		* delta
	
		#impulse /= floatersCount
		
#		print("depth ", h)
#		print("submerged ", submerged)
#		print("impulse ",impulse)
		
		body.add_force(-gravity_vector * impulse,
		global_offset)
	
	body.add_central_force(float(apply_gravity) * gravity_vector * 9.8 * body.mass)
		
		
#
#		var vel: Vector3 =  body.linear_velocity
#		vel.y *= 0.9 * delta
#		body.linear_velocity = vel
#		body.angular_velocity *= 0.9
