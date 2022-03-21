extends RigidBody


onready var force_offset = $ForceOffset
onready var debug = $ForceDebug

export(float) var lift_force = 20.0
export(float) var direct_force = 40.0
export(float) var dead_angle = deg2rad(1) setget set_dead_angle, get_dead_angle

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_dead_angle(val: float):
	dead_angle = deg2rad(val)
	
func get_dead_angle() -> float:
	return rad2deg(dead_angle)
	
func dead_angle_quotient(angle: float) ->float:
	var a = -1/dead_angle
	var q = a* angle -a * PI
	return clamp(q, 0,1)

func _physics_process(delta):
	#print("dead angle: ", dead_angle)
	var global_force_normal : Vector3 = global_transform.basis.xform(Vector3.RIGHT).normalized()
	var global_heading_hormal : Vector3 = -global_transform.basis.xform(Vector3.FORWARD).normalized()
	var global_offset = force_offset.to_global(Vector3()) - to_global(Vector3())
	var global_wind : Vector3 = Vector3.RIGHT

	var wind_alpha: float = global_heading_hormal.angle_to(global_wind)#global_wind.angle_to(global_heading_hormal)
	var c = cos(wind_alpha)
	var s = sin(wind_alpha)
	var dead_zone = dead_angle_quotient(wind_alpha)
	var side = sign(global_heading_hormal.cross(global_wind).y)
	var direct: float = s * direct_force
	var lift: float  = dead_zone* -clamp(c,-1,0) * lift_force
	var global_force: Vector3 =  side * (lift + direct) * global_force_normal
	#print("angle: ", rad2deg(wind_alpha))
	#print("dead: ", dead_zone)

	add_force(global_force * delta, global_offset) 

	#var sail_fill = (lift + direct) / (lift_force + direct_force)
	#mainsail.scale.x = -side* sail_fill * 2

	debug.clear()
	debug.draw(global_force * 0.1, Color.aqua)
	debug.draw(global_heading_hormal, Color.green)
	debug.draw(global_wind, Color.red)
