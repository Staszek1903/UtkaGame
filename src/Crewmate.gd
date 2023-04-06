extends Spatial

export(NodePath) var path_path = NodePath("../Path")

var curve:Curve3D
var steering_points:Node
var assigned_point:Node = null

const speed:float = 1.5
const work_distance:float = 0.5

onready var boat = get_parent().get_parent()

func _ready():
	curve = get_node(path_path).curve
	assert(curve)

var target_id = null
var target_pos:Vector2
func _process(delta):
	update_hunger(delta)
	
	var origin_pos = Vector2(transform.origin.x,
							transform.origin.z)
	
	if assigned_point:
		var p = assigned_point.transform.origin
		target_pos = Vector2(p.x,p.z)
		var distance = target_pos.distance_to(origin_pos)
		if distance < work_distance: 
			assigned_point.is_manned = true
#			$AnimationPlayer.play("SitDown")
			return
		
		var direction = (target_pos - origin_pos).normalized()
		var offset = direction * delta * speed
		var direction3 = Vector3(offset.x,0,offset.y)
		transform.origin += direction3

		transform.basis.z = direction3
		transform.basis.y = Vector3.UP
		transform.basis.x = Vector3.UP.cross(-direction3)
		transform.basis = transform.basis.orthonormalized()
#		if not $AnimationPlayer.is_playing():
#			$AnimationPlayer.play("Walk")
		return

	if not target_id:
		target_id = find_closest_id()
		var p = curve.get_point_position(target_id)
		target_pos = Vector2(p.x,p.z)
	
	var distance = target_pos.distance_to(origin_pos)
	if distance < work_distance:
		target_id = \
			wrapi(target_id + 1, 0, curve.get_point_count())
		var p =  curve.get_point_position(target_id)
		target_pos = Vector2(p.x,p.z)
		
	var direction = (target_pos - origin_pos).normalized()
	var offset = direction * delta * speed
	var direction3 = Vector3(offset.x,0,offset.y)
	transform.origin += direction3
	
	transform.basis.z = direction3
	transform.basis.y = Vector3.UP
	transform.basis.x = Vector3.UP.cross(-direction3)
	transform.basis = transform.basis.orthonormalized()
	if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("Walk")
	#transform.basis.y = Vector3.DOWN

	
func find_closest_id() -> int:
	var closest_distance:float = 99999.0 #ship is smaller
	var closes_id:int = 0
	for i in curve.get_point_count():
		var p:Vector3 = curve.get_point_position(i)
		var d:float = p.distance_to(transform.origin)
		if d < closest_distance:
			closest_distance = d
			closes_id = i
	return closes_id

const hunger_time:float = 240.0
var hunger:float = 0
var fatigue:float = 0

func update_hunger(delta:float):
	fatigue += delta
	hunger += delta
	if hunger > hunger_time:
		if boat.has_method("consume_food_portion"):
			if boat.consume_food_portion():
				print("CREWMATE CONSUMPTION")
				hunger = 0.0
				
	$StarvationInd.visible = hunger > hunger_time
	
	var starvation = hunger - hunger_time
	#var hunger_val = 1.0 - (hunger / hunger_time)
	var starvation_val = 1.0 - (starvation / hunger_time)
	if starvation_val <= 0.0:
		print("CREWMATE STARVED")
		get_parent().crew.erase(self)
		$AnimationPlayer.play("Death")
		yield($AnimationPlayer,"animation_finished")
		queue_free()
		

	#hunger_bar.set_hunger_level(hunger_val)
	#hunger_bar.set_starvation_level(starvation_val)
