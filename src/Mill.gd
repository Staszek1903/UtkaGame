extends Spatial

onready var pivot = $Pivot
const speed:float = 0.7

func _process(delta):
	pivot.rotation.z += speed*delta
