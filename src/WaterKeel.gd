extends Spatial

onready var proto = $WaterKeel
export(int) var riple_count = 5
var riples = []
var first = 0

func _ready():
	proto.get_parent().remove_child(proto)
	get_tree().get_root().add_child(proto)
	riples.append(proto)
	
	var proto_mat = proto.get_surface_material(0)

	for i in riple_count:
		var new = proto.duplicate()
		get_tree().get_root().add_child(new)
		riples.append(new)
		new.global_transform.origin = global_transform.origin
		
		new.set_surface_material(0, proto_mat.duplicate())


func _process(delta):
	for r in riples:
		r.scale.x += delta * 1.1
		r.scale.y += delta * 1.1
		r.scale.z = 4.0
		var tint = r.get_surface_material(0).get_shader_param("albedo_tint")
		tint.a  = clamp(tint.a - delta * 0.5, 0.0 , 1.0)
		r.get_surface_material(0).set_shader_param("albedo_tint", tint)

	var length:Vector3 = riples[first].global_transform.origin \
		- global_transform.origin
	
	if length.length_squared() > 1.0:
		var last = wrapi(first-1, 0, riples.size())
		riples[last].global_transform.origin \
			 = global_transform.origin
		riples[last].scale.x = 0.0
		riples[last].scale.y = 0.0
		riples[last].get_surface_material(0) \
			.set_shader_param("albedo_tint", Color.white)
		first = last
