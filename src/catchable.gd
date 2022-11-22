extends RigidBody
class_name Catchable

# Item = {name, quantity}

export(Dictionary) var items = {}

#export(ItemsEnum.Items) var item
#export(int) var price = 100

func _ready():
	for key in items.keys():
		assert(key is String)
	for val in items.values():
		assert(val is int)
		
	add_to_group("catchable")
	
func remove_catchable():
	print("REMOVE CATCHABLE")
	queue_free()
