extends Control

func set_boat(body:RigidBody):
	$TiltInd.body = body
	$SpeedInd.body = body
	$WindInd.body = body
	$HeadingInd.body = body
