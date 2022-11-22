extends Label

onready var tween = $Tween

var cash_amount:int = 0 setget set_cash_amount

func _ready():
	call_deferred("set_cash_amount", 100)

func set_cash_amount(val:int):
	var tween_time = 5.0 #abs(float(cash_amount - val)/10.0)
	#print("TWEEN TIME: ", tween_time)
	
	tween.interpolate_method(self, "update_text", cash_amount, val,
		tween_time,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT)
	tween.start()
	cash_amount = val

func update_text(val:int):
	#print("text_updated ", val)
	text = "%d $" % val
