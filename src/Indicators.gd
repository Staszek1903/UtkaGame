extends Control

func set_boat(body:RigidBody, boom:RigidBody):
	$WindInd.body = body
	$WindInd.boom = boom
	$TiltInd.body = body
	$SpeedInd.body = body
	$HeadingInd.body = body
