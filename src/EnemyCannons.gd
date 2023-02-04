extends Spatial

#onready var camera_pivot = $"../CameraPivot"
#onready var camera = $"../CameraPivot/Camera"
export(bool) var active:bool = true
onready var cannons = [$Cannon1, $Cannon4, $Cannon2, $Cannon5, $Cannon3, $Cannon6]
onready var boat = get_parent()
var target_boat:Spatial = null
var range_dist:float = 50.0

#var cannons_count = 0
#var aim:bool = false

#func _ready():
#	assert(camera_pivot)
#	assert(camera)

#func add_cannon():
#	print("ADDING_CANNON")
#	cannons_count = clamp(cannons_count+1, 0, cannons.size())
#	for i in cannons_count:
#		cannons[i].visible = true

func _process(_delta):
	if not target_boat: return
	if not active: return
	var dist_sq = boat.global_transform.origin.distance_squared_to(
		target_boat.global_transform.origin)
	
	#print("AAA")
	if dist_sq < range_dist * range_dist:
		if update_trim():
			fire()
		
		

		
#func _input(event):
#	if not camera.current: return
#	if event is InputEventMouseButton \
#	and event.button_index == BUTTON_RIGHT:
#		aim = event.pressed
#		update_aim()
#	elif event is InputEventMouseMotion and aim:
#		update_trim()
#		update_aim()
		
#func update_aim():
#	var side:int = get_camera_side()
#	for i in cannons_count:
#		if i % 2 == side : cannons[i].aim_cone.visible = aim
#		else: cannons[i].aim_cone.visible = false

func get_target_side() -> float:
	var nav_vect = boat.global_transform.origin \
	- target_boat.global_transform.origin
	var hdg_vect = boat.global_transform.basis.z
	var board_side:float = hdg_vect.cross(nav_vect).dot(Vector3.DOWN)
	return board_side

func get_target_yaw() -> float:
	var nav_vect = boat.global_transform.origin \
	- target_boat.global_transform.origin
	var forward_vect = boat.global_transform.basis.z
	
	var global_nav_angle = atan2(nav_vect.x, nav_vect.z)
	var boat_angle = atan2(forward_vect.x, forward_vect.z)
	
	var relative_nav_angle = wrapf(global_nav_angle - boat_angle,0.0,PI*2.0)
	
	return relative_nav_angle
	
#func get_camera_pitch() -> float:
#	return camera_pivot.transform.basis.z.dot(Vector3.DOWN)
	
func update_trim() -> bool:
	
	#print(self, " ", camera_pivot.transform.basis.get_euler())
	var side = sign(get_target_side())
	side = 0 if side < 0.0 else 1
	var yaw = get_target_yaw() 
	var pitch = 0 #get_camera_pitch()
	#print("YAW: ", yaw)
	
	if( yaw < 1.0708 \
	or (yaw > 2.0708 and yaw < 4.21239) \
	or yaw > 5.21239 ): 
		return false
	
	for i in cannons.size():
		if i % 2 == side :
			cannons[i].rotation.y = yaw
			cannons[i].set_pitch(pitch)

	return true
			
func fire():
	var side = get_target_side()
	side = 0 if side < 0.0 else 1
	
	#print("SIDE: ", side)
	
	var delay = 0.2

	for i in cannons.size():
		if i % 2 == side :
			cannons[i].fire()
			yield(get_tree().create_timer(delay), "timeout")


func _on_ArgArea_body_entered(body):
	if body.is_in_group("boat") and body.is_current():
		target_boat = body


func _on_ArgArea_body_exited(body):
	if body == target_boat:
		target_boat = null
