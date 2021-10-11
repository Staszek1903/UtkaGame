tool
extends Spatial

export(float) var segment_length = 1.0
export(float) var segment_thicc = 0.1
export(float, 0.0, 2.0) var relative_len = 1.5
export(Color) var color = Color.brown
export(NodePath) var atachmentNodePathA:NodePath
export(NodePath) var atachmentNodePathB:NodePath
export(Vector3) var offsetA:Vector3
export(Vector3) var offsetB:Vector3

onready var endA = $EndA
onready var endB = $EndB

var atachmentNodeA:Spatial
var atachmentNodeB:Spatial

var points = []

func _ready():
	if atachmentNodePathA:
		atachmentNodeA = get_node(atachmentNodePathA)
#		offsetA = $EndA.global_transform.origin - atachmentNodeA.global_transform.origin
#		offsetA = atachmentNodeA.global_transform.basis.xform_inv(offsetA)
	if atachmentNodePathB:
		atachmentNodeB = get_node(atachmentNodePathB)
#		offsetB = $EndB.global_transform.origin - atachmentNodeB.global_transform.origin
#		offsetB = atachmentNodeB.global_transform.basis.xform_inv(offsetB)

func _process(delta):
	add_points()
	draw_rope()
	update_ends_pos()
	
func _physics_process(delta):
	#gravity
	for i in points.size():
		points[i] += Vector3.DOWN * 9.8 * delta
		
	var posA = $EndA.transform.origin
	var posB = $EndB.transform.origin
	
	#cloth algorithm
	for j in 3:
		var target = posA
		for i in points.size():
			points[i] = adj_point(points[i],target,segment_length)
			target = points[i]
		
		target = posB
		for i in range(points.size()-1, -1, -1):
			points[i] = adj_point(points[i],target,segment_length)
			target = points[i]
	
func adj_point(point:Vector3, target:Vector3, seg_len:float)-> Vector3:
	var vect = target - point
	vect = vect.normalized() * seg_len
	return (target - vect)

func add_points():
	var posA = $EndA.transform.origin
	var posB = $EndB.transform.origin
	var first_pos  = points[points.size()-1] if points.size()>0 else posA
	var cur_len = (posA-posB).length()
	while((points.size()+1) * segment_length < cur_len * relative_len):
		first_pos = (first_pos + posB)/2.0
		points.append(first_pos)
		#print(first_pos, " point added ", points.size())
		
	while(points.size() * segment_length > cur_len * relative_len):
		points.remove(points.size()-1)
		#print(first_pos, " point removed ", points.size())

func draw_rope():
	var linedraw:ImmediateGeometry = $LineDraw
	var posA = $EndA.transform.origin
	var posB = $EndB.transform.origin
	
	linedraw.clear()
	linedraw.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	linedraw.set_color(color)
	
	var prev_point = posA
#	var point_normal:Vector3 = (points[0] - prev_point).normalized()
#	var perpend_vect =point_normal.cross(point_normal.rotated(Vector3.UP,3))
#	var perpend2_vect = point_normal.cross(perpend_vect)
#	var edge_vect = perpend_vect.normalized() * (segment_thicc/2.0)
#	var edge_vect2 = perpend2_vect.normalized() * (segment_thicc/2.0)
#	var pedge_vect = edge_vect
#	var pedge_vect2 = edge_vect2
	
	
	for i in range(0,points.size()):
		var point_normal = (points[i] - prev_point).normalized()
		var perpend_vect =point_normal.cross(point_normal.rotated(Vector3.UP,3))
		var perpend2_vect = point_normal.cross(perpend_vect)
		var edge_vect = perpend_vect.normalized() * (segment_thicc/2.0)
		var edge_vect2 = perpend2_vect.normalized() * (segment_thicc/2.0)
		linedraw.add_vertex(prev_point + edge_vect)
		linedraw.add_vertex(prev_point - edge_vect)
		linedraw.add_vertex(points[i] + edge_vect)
		linedraw.add_vertex(points[i] - edge_vect)
		
		linedraw.add_vertex(prev_point + edge_vect2)
		linedraw.add_vertex(prev_point - edge_vect2)
		linedraw.add_vertex(points[i] + edge_vect2)
		linedraw.add_vertex(points[i] - edge_vect2)
		
		prev_point = points[i]
	
	var point_normal = (posB - prev_point).normalized()
	var perpend_vect =point_normal.cross(point_normal.rotated(Vector3.UP,3))
	var perpend2_vect = point_normal.cross(perpend_vect)
	var edge_vect = perpend_vect.normalized() * (segment_thicc/2.0)
	var edge_vect2 = perpend2_vect.normalized() * (segment_thicc/2.0)
	linedraw.add_vertex(prev_point + edge_vect)
	linedraw.add_vertex(prev_point - edge_vect)
	linedraw.add_vertex(posB + edge_vect)
	linedraw.add_vertex(posB - edge_vect)
	
	linedraw.add_vertex(prev_point + edge_vect2)
	linedraw.add_vertex(prev_point - edge_vect2)
	linedraw.add_vertex(posB + edge_vect2)
	linedraw.add_vertex(posB - edge_vect2)
	linedraw.end()

func update_ends_pos():
	if not atachmentNodeA or not atachmentNodeB : return
	var offA = atachmentNodeA.global_transform.basis.xform(offsetA)
	var offB = atachmentNodeB.global_transform.basis.xform(offsetB)
	endA.global_transform.origin = atachmentNodeA.global_transform.origin + offA
	endB.global_transform.origin = atachmentNodeB.global_transform.origin + offB
	
func apply_force(magnitude:float):
	if not atachmentNodeA or not atachmentNodeB : return  
	var pointA = atachmentNodeA.global_transform.basis.xform(offsetA)
	var pointB = atachmentNodeB.global_transform.basis.xform(offsetA)
	var global_posA = pointA + atachmentNodeA.global_transform.origin
	var global_posB = pointB + atachmentNodeB.global_transform.origin
	var difference_vect:Vector3 = endA.global_transform.origin - endB.global_transform.origin
	
	var force = difference_vect.normalized() * magnitude
	
	if atachmentNodeB is RigidBody:
		atachmentNodeB.add_force(force, pointB)
		$EndB/ForceDebug.clear()
		$EndB/ForceDebug.draw(force*10)
	if atachmentNodeA is RigidBody:
		atachmentNodeA.add_force(-force, pointA)
		$EndA/ForceDebug.clear()
		$EndA/ForceDebug.draw(-force*10)
	
	
	
