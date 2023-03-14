extends Spatial

onready var arrow:Spatial = $Arrow
onready var tween:Tween = $Tween
#var mouse_pos:Vector3 = Vector3(1.0,0,0)

var target_angle:float = 0.0
var angle_vel:float = 0.0

func _on_Area_input_event(_camera, _event, click_position, _click_normal, _shape_idx):
	#mouse_pos = click_position
	var target_vect = click_position - global_transform.origin
	var local_target_vect = global_transform.basis.xform_inv(target_vect)
	var angle = atan2(local_target_vect.x, local_target_vect.z)
	target_angle = angle
	
	
#	tween.remove_all()
#	tween.interpolate_property(arrow, "rotation:y",
#		arrow.rotation.y,
#		angle,2,
#		Tween.TRANS_ELASTIC,
#		Tween.EASE_OUT)
#	tween.start()
	

func angle_difference(angle1, angle2):
	var diff = angle2 - angle1
	return diff if abs(diff) < PI else diff + (2*PI* -sign(diff))

func _physics_process(delta):
	var angle_error = angle_difference(arrow.rotation.y, target_angle)
	#print(angle_error)
	angle_vel += angle_error * delta * 20.0
	angle_vel -= angle_vel * delta * 1.7
	arrow.rotation.y += angle_vel * delta
	
