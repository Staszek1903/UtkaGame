extends Position2D

export(PackedScene) var scene = preload("res://scenes/SmallIsland.tscn") \
	setget set_scene
var prototype

#func _init():
#	print("ISLAND SCENE: ", scene, " ", prototype)

func set_scene(_scene:PackedScene):
	scene = _scene
	prototype = scene.instance()
	#print("SET_SCENE: ", scene, " ", prototype)
