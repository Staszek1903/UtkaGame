extends Node2D

var body: RigidBody

onready var needle = $Needle
onready var needleAux = $NeedleAux
onready var label_angle = $PanelAngle/Label
onready var label_speed = $PanelSpeed/Label
onready var wind_manager = $"/root/WindManager"

func _ready():
	assert(wind_manager)

func _process(_delta):
	if body:
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
		label_angle.text = str(abs(int(rad2deg(angle))))
		label_speed.text = str(float(int(local_wind.length()*10.0))*0.1)
