extends ImmediateGeometry

func draw(global_vect: Vector3, color = Color.darkorchid,
offset = Vector3()):
	var debug = global_transform.basis.xform_inv(global_vect)
	#var debug = global_vect
	begin(Mesh.PRIMITIVE_LINES)
	set_color(color)
	add_vertex(Vector3())
	add_vertex(debug)
	end()
