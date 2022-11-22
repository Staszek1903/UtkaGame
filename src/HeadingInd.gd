extends Node2D

var body: RigidBody

onready var needle = $Needle
onready var label = $PanelContainer/Label

func _process(_delta):
	if body:
		var basis = body.global_transform.basis
		var angle = atan2(basis.z.x, basis.z.z)
		needle.rotation = angle
		var label_angle = -angle + PI*2.5
		label.text = str(int(rad2deg(label_angle)) % 360 )
