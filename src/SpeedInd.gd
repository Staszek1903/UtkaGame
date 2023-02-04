extends Node2D
var body: RigidBody = null

onready var needle = $Needle
onready var label = $PanelContainer/Label
	
func _process(_delta):
	if body and is_instance_valid(body):
		var vel = body.linear_velocity
		vel = body.global_transform.basis.xform_inv(vel)
		var s:float = -vel.z
		needle.rotation = s
		s = float(int(s*10.0))/10.0
		label.text = str(s)
