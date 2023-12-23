extends Node2D

var body: RigidBody = null
var boom: RigidBody = null

onready var needle = $Needle
onready var needleAux = $NeedleAux
onready var mainSail = $MainSail
onready var label_angle = $PanelAngle/Label
onready var label_speed = $PanelSpeed/Label
onready var wind_manager = $"/root/WindManager"

export(Resource) var mainsail_gradient = Gradient.new()

func _ready():
	assert(wind_manager)

func _process(_delta):
	if body and is_instance_valid(body):
		var basis = body.global_transform.basis
		var global_real_wind : Vector3 = wind_manager.global_wind_vector \
			* wind_manager.wind_speed
		var global_wind = global_real_wind - body.linear_velocity # real wind to relative wind
		
		var local_real_wind = basis.xform_inv(global_real_wind)
		var local_wind = basis.xform_inv(global_wind)
		var real_angle = -atan2(local_real_wind.x, local_real_wind.z)
		var angle = -atan2(local_wind.x, local_wind.z)
		needleAux.rotation = real_angle
		needle.rotation = angle
		#label_angle.text = str(abs(int(rad2deg(angle))))
		#label_speed.text = str(float(int(local_wind.length()*10.0))*0.1)
		
	if boom and is_instance_valid(boom):
		var angle:float = body.global_transform.basis.z.angle_to(
			boom.global_transform.basis.z) \
			* -sign(boom.global_transform.basis.z.dot(
			body.global_transform.basis.x))
		mainSail.rotation = angle 
		mainSail.color = mainsail_gradient.interpolate(boom.current_sail_efficiency)
		#label_angle.text = str(boom.current_sail_efficiency)
