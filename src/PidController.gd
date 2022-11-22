extends Node

export(float) var K_proportional = 50.0
export(float) var K_integral = 0.1
export(float) var K_derivative = 1000

var last_error = 0.0
var integral = 0.0

func integrate(error:float) -> float:
	var propotional = K_proportional * error
	integral += K_integral * error
	integral = clamp(integral,-1,1)
	var derivative = K_derivative*(error-last_error)

	last_error = error
	return propotional+integral+derivative
