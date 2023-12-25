extends RigidBody
class_name Catchable

signal freed(item)

export(Dictionary) var items = {}

func _ready():
	for key in items.keys():
		assert(key is String)
	for val in items.values():
		assert(val is int)
		
	add_to_group("catchable")
	
func add_item(name:String, count:int):
	if not name in items.keys():
		items[name] = 0
	items[name] += count
	
func remove_catchable():
	print("REMOVE CATCHABLE")
	emit_signal("freed",self)
	queue_free()

onready var particles = $Particles
func _process(delta):
	if particles: particles.global_transform.basis = Basis()
