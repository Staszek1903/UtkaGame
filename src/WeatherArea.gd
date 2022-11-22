extends Area

onready var water_manager:WaterManager = $"/root/Root/WaterManager"

export(float) var wave_amp:float = 0.2
export(float) var wave_freq:float = 0.3

func _read():
	assert(water_manager)

func _on_WeatherArea_body_entered(body):
	if body.name != "Boat": return
	water_manager.set_next_amplitude(wave_amp)
	water_manager.set_next_frequency(wave_freq)
	
