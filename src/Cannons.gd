extends Spatial

onready var camera_pivot = $"../CameraPivot"
onready var camera = $"../CameraPivot/Camera"
onready var cannons = [$Cannon1, $Cannon4, $Cannon2, $Cannon5, $Cannon3, $Cannon6]

var cannons_count:int = 0 setget set_cannons_cout
var aim:bool = false

func _ready():
	assert(camera_pivot)
	assert(camera)
	
func set_cannons_cout(val:int):
	cannons_count = clamp(val, 0, cannons.size())
	for i in cannons_count:
		cannons[i].visible = true

func add_cannon():
	print("ADDING_CANNON")
	cannons_count = clamp(cannons_count+1, 0, cannons.size())
	for i in cannons_count:
		cannons[i].visible = true
		
func fire():
	var side:int = get_camera_side()
	print("SIDE: ", side)
	
	var delay = 0.2

	for i in cannons_count:
		if i % 2 == side :
			cannons[i].fire()
			yield(get_tree().create_timer(delay), "timeout")
		
func _input(event):
	if not camera.current: return
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_RIGHT:
		aim = event.pressed
		update_aim()
	elif event is InputEventMouseMotion and aim:
		update_trim()
		update_aim()
		
func update_aim():
	var side:int = get_camera_side()
	for i in cannons_count:
		if i % 2 == side : cannons[i].aim_cone.visible = aim
		else: cannons[i].aim_cone.visible = false

func get_camera_side() -> int:
		var side = camera_pivot.transform.basis.z.dot(Vector3.RIGHT)
		return (0 if side > 0.0 else 1)

func get_camera_yaw() -> float:
	return camera_pivot.transform.basis.z.dot(Vector3.FORWARD)
	
func get_camera_pitch() -> float:
	return camera_pivot.transform.basis.z.dot(Vector3.DOWN)
	
func update_trim():
	#print(self, " ", camera_pivot.transform.basis.get_euler())
	var side = get_camera_side()
	var side_normalized = 1 - side * 2 # (0;1) -> (1,-1)
	var yaw = get_camera_yaw() 
	var pitch = get_camera_pitch()
	for i in cannons_count:
		if i % 2 == side :
			cannons[i].rotation.y = \
			side_normalized * (PI * 0.5 + yaw)
			cannons[i].set_pitch(pitch)
			
