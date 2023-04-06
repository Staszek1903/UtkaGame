extends Node

export(bool) var active:bool = false
export(float) var range_distance:float = 50.0

onready var control = get_parent()


func _ready():
	pass
	
func _process(_delta):
	if not active: return
	if not control.player_boat: return
	
	var dist_sq:float = control.boat.global_transform.origin.distance_squared_to(
		control.player_boat.global_transform.origin
	)
	
	#print(sqrt(dist_sq))
		
	if dist_sq < range_distance*range_distance:
		in_range_targeting()
	else:
		out_of_range_targeting()
	

func out_of_range_targeting():
	var nav_vector:Vector3 = control.boat.global_transform.origin\
	 - control.player_boat.global_transform.origin\
	
	var player_speed:Vector3 = control.player_boat.linear_velocity
	var target_point = nav_vector - (player_speed * nav_vector.length() * 0.2)
	
	control.target_angle = atan2(target_point.x, target_point.z)

	# TODO CANNONS


func in_range_targeting():
	var player_forward:Vector3 = control.player_boat.global_transform.basis.z
	var player_hdg:float = atan2(player_forward.x, player_forward.z)
	#var player_hdg_y:float = control.boat.global_transform.basis.get_euler().y
	
	var nav_vector:Vector3 = control.player_boat.global_transform.origin\
	- control.boat.global_transform.origin
	
	var ai_forward:Vector3 = control.boat.global_transform.basis.z
#	var ai_hdg = atan2(ai_forward.x, ai_forward.z)
	var board_side:float = ai_forward.cross(nav_vector).dot(Vector3.DOWN)
	
	
	var nav_hdg:float = atan2(nav_vector.x, nav_vector.z)
	var nav_hdg90:float = \
	wrapf(nav_hdg + (PI*0.5*sign(board_side)), 0.0, PI*2.0)
	
	var forward_pos:float = player_forward.dot(nav_vector.normalized())
	#print("FWD POS: ", forward_pos)
	
	if forward_pos > 0.0:
		control.target_angle = nav_hdg90
	else:
		control.target_angle = player_hdg



