extends Control

export(NodePath) var body_path
var body: RigidBody = null

func _ready():
	body = get_node(body_path)
	$TiltInd.body = body
	$SpeedInd.body = body
	$WindInd.body = body
	$HeadingInd.body = body
