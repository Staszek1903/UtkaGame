extends Spatial


func _ready():
	pass

func light_the_candle():
	$OmniLight.visible = true
	$CSGSphere.visible = true
	$CSGMesh.visible = true
