extends RayCast


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var meshInst = $"../WaterTile/WaterMesh"
	#meshInst.create_debug_tangents()
	#meshInst.create_convex_collision()


#var time:float = 0
#func _process(delta):
#	time += delta;
#	if( time > 1.0 ):
#		print(is_colliding())
#		print(get_collision_point()," ", get_collision_normal(), " ", get_collider())
#		time = 0.0
