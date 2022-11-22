extends ImmediateGeometry

onready var points = get_parent().curve.get_baked_points()

func _ready():
	begin(Mesh.PRIMITIVE_LINES)
	for i in points:
		add_vertex(i)
	end()
