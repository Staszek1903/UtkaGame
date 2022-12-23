extends Spatial

onready var camera_pivot = $"../CameraPivot"
onready var cannons = [$Cannon1, $Cannon4, $Cannon2, $Cannon5, $Cannon3, $Cannon6]

var cannons_count = 0

func _ready():
	assert(camera_pivot)

func add_cannon():
	print("ADDING_CANNON")
	cannons_count = clamp(cannons_count+1, 0, cannons.size())
	for i in cannons_count:
		cannons[i].visible = true
		
func fire():
	for i in cannons_count:
		cannons[i].fire()
