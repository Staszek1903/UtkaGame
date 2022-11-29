tool
extends Spatial

export(float) var segment_length = 1.0
export(float) var segment_thicc = 0.1
export(float) var length = 1.0 setget set_length
export(float) var max_length = 10.0
export(Color) var color = Color.brown
export(NodePath) var atachmentNodePathA:NodePath
export(NodePath) var atachmentNodePathB:NodePath
export(Vector3) var offsetA:Vector3
export(Vector3) var offsetB:Vector3
export(bool) var fsx_enabled:bool = true

onready var endA = $EndA
onready var endB = $EndB

#onready var joint:Generic6DOFJoint = $Generic6DOFJoint

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
	update_ends_pos()
	add_points()
	
	#gravity
	for i in points.size():
		points[i] += Vector3.DOWN * 9.8 * delta
		
	var posA = $EndA.transform.origin
	var posB = $EndB.transform.origin
	
	#cloth algorithm
	for j in 10:
		var target = posA
		for i in points.size():
			points[i] = adjust_point(points[i],target,segment_length)
			target = points[i]
		
		target = posB
		for i in range(points.size()-1, -1, -1):
			points[i] = adjust_point(points[i],target,segment_length)
			target = points[i]
			
	draw_rope()


func _physics_process(delta):
	if fsx_enabled: apply_force()

#	var posA = $EndA.transform.origin
#	var posB = $EndB.transform.origin
#	print(length, " ", (posA - posB).length())
	
	
func adjust_point(point:Vector3, target:Vector3, seg_len:float)-> Vector3:
	var vect = target - point
	vect = vect.normalized() * seg_len
	return (target - vect)

func add_points():
	var posA = $EndA.transform.origin
	var posB = $EndB.transform.origin
	var first_pos  = points[points.size()-1] if points.size()>0 else posA
	
	while((points.size()+1) * segment_length < length):
		first_pos = (first_pos + posB)/2.0
		points.append(first_pos)
		#print(first_pos, " point added ", points.size())
		
	while(points.size() * segment_length > length):
		points.remove(points.size()-1)
		#print(first_pos, " point removed ", points.size())

func get_point_vertices(point: Vector3, normal: Vector3):
	normal = normal.normalized()
	var perpend_vect =normal.cross(normal.rotated(Vector3.UP,3))
	var perpend2_vect = normal.cross(perpend_vect)
	var edge_vect = perpend_vect.normalized() * (segment_thicc/2.0)
	var edge_vect2 = perpend2_vect.normalized() * (segment_thicc/2.0)
	return [point + edge_vect, point + edge_vect2,
			point - edge_vect, point - edge_vect2]
			
func triangle_normal(a,b,c):
	return (b-a).cross(c-a).normalized()

func get_point_normal(index:int) -> Vector3:
	var prev_pos:Vector3
	var next_pos:Vector3
	if index == -1:
		prev_pos = $EndA.transform.origin
		next_pos = $EndB.transform.origin \
			if points.size() == 0 else points[0]
	elif index >= points.size():
		prev_pos = $EndA.transform.origin \
			if points.size() == 0 else points[points.size()-1]
		next_pos = $EndB.transform.origin
	else:
		prev_pos = points[index]
		next_pos = $EndB.transform.origin \
			if index >= points.size()-1 else points[index-1]
		
	return (next_pos - prev_pos).normalized()

func get_point(index:int) -> Vector3:
	if index == -1: return $EndA.transform.origin
	elif index == points.size(): return $EndB.transform.origin
	else: return points[index]

func draw_segment(vertsA, vertsB, linedraw):
	linedraw.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	linedraw.set_color(color)
	linedraw.add_vertex(vertsA[0])
	linedraw.add_vertex(vertsB[0])
	linedraw.add_vertex(vertsA[1])
	linedraw.add_vertex(vertsB[1])
	linedraw.add_vertex(vertsA[2])
	linedraw.add_vertex(vertsB[2])
	linedraw.add_vertex(vertsA[3])
	linedraw.add_vertex(vertsB[3])
	linedraw.add_vertex(vertsA[0])
	linedraw.add_vertex(vertsB[0])
	linedraw.end()

func draw_rope():
	var linedraw:ImmediateGeometry = $LineDraw
	linedraw.clear()
	var pointA:Vector3 = get_point(-1)
	var normalA:Vector3 = get_point_normal(-1)
	var vertsA = get_point_vertices(pointA, normalA)
	
	for i in range(0,points.size()+1):
		var pointB:Vector3 = get_point(i)
		var normalB:Vector3 = get_point_normal(i)
		var vertsB = get_point_vertices(pointB, normalB)
		draw_segment(vertsA,vertsB,linedraw)
		vertsA = vertsB

func update_ends_pos():
	if not atachmentNodeA or not atachmentNodeB : return
	var offA = atachmentNodeA.global_transform.basis.xform(offsetA)
	var offB = atachmentNodeB.global_transform.basis.xform(offsetB)
	endA.global_transform.origin = atachmentNodeA.global_transform.origin + offA
	endB.global_transform.origin = atachmentNodeB.global_transform.origin + offB
	
	
func apply_force(magnitude:float = 0.0):
	if not atachmentNodeA or not atachmentNodeB : return
	var aNA = atachmentNodeA
	var aNB = atachmentNodeB
	if not aNA is RigidBody: 
		aNA = aNA.get_parent()
	if not aNB is RigidBody: 
		aNB = aNB.get_parent()
	if not aNA is RigidBody and not aNB is RigidBody: return
	
	var pointA = aNA.global_transform.basis.xform(offsetA)
	var pointB = aNB.global_transform.basis.xform(offsetA)
	var global_posA = pointA + aNA.global_transform.origin
	var global_posB = pointB + aNB.global_transform.origin
	var difference_vect:Vector3 = endA.global_transform.origin - endB.global_transform.origin
	
	var stretch = difference_vect.length() - length
	if stretch < 0.0: return
	stretch = clamp(stretch, 0.0, 1.0)
	magnitude = pow(stretch,10)*50.0
	
#	var massA = 0.0
#	var massB = 0.0
#
#	if aNA is RigidBody:
#		massA = aNA.mass
#	if aNB is RigidBody:
#		massB = aNB.mass
	#print(stretch)
	
	var force = difference_vect.normalized() * magnitude #* (massA + massB)
	
	$EndB/ForceDebug.clear()
	$EndA/ForceDebug.clear()
	if aNB is RigidBody:
		aNB.add_force(force, pointB)  
		$EndB/ForceDebug.draw(force*10)
	if aNA is RigidBody:
		aNA.add_force(-force, pointA)
		$EndA/ForceDebug.draw(-force*10)
	
func set_length(val):
	length = val
	if length < 0.0:
		if not atachmentNodeA or not atachmentNodeB : 
			length = 0.0
			return  
		var pointA = atachmentNodeA.global_transform.basis.xform(offsetA)
		var pointB = atachmentNodeB.global_transform.basis.xform(offsetA)
		var global_posA = pointA + atachmentNodeA.global_transform.origin
		var global_posB = pointB + atachmentNodeB.global_transform.origin
		var difference_vect:Vector3 = endA.global_transform.origin - endB.global_transform.origin
		length = difference_vect.length()
		print("rope ustawioned na ", length)
		
	length = clamp(length, 0.0, max_length)
		
func change_length(d):
	set_length(length + d)
	
func heave_rope(delta):
	set_length(length - delta)

func ease_rope(delta):
	set_length(length + delta)
