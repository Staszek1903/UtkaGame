extends Node2D

var body: Spatial = null

onready var needle = $Needle
onready var label = $PanelContainer/Label
	
func _process(delta):
	if body:
		var basis:Basis = body.global_transform.basis
		var for_vect = basis.z
		var horizontal_angle = atan2(for_vect.x, for_vect.z)
		var up_vect:Vector3 = basis.y
		up_vect = up_vect.rotated(Vector3(0.0,1.0,0.0), -horizontal_angle);
		var angle = atan2(up_vect.x,up_vect.y)
		needle.rotation = angle
		label.text = str(int(rad2deg(angle)))

