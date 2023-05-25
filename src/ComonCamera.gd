extends Camera

onready var waterManager = $"/root/Root/WaterManager"
onready var bulbul = $BulBulMesh
onready var water_audio = $WaterAudio

func _process(_delta):
	if not waterManager or not is_instance_valid(waterManager):
		return

	var global_pos = global_transform.origin
	var h = global_pos.y
	var wave_h = 0.0
	
	if waterManager:
		wave_h = waterManager.wave(
			Vector2(global_pos.x, global_pos.z)
			)
	
	h = h - wave_h
	var underwater:bool =  h < 0.0;
	bulbul.visible = underwater
	water_audio.pitch_scale = 0.2 if underwater else 0.7
