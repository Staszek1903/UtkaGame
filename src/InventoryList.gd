extends Control

var is_shown:bool = false

onready var inv_container:VBoxContainer = $VBoxContainer/YourInventory/ItemList
onready var cash_label = $VBoxContainer/CashLabel
onready var amount_label = $VBoxContainer/AmountLabel
onready var slider: HSlider = $VBoxContainer/AmountSlider
onready var button:Button = $VBoxContainer/Button

onready var trade_interface = $"/root/TradeInterface"
onready var backend = $"/root/Inventory"

var current_item:int = 0

func _ready():
	assert(trade_interface)
	assert(backend)
	inv_container.set_item_list(backend.inventory)
	update_cash_label()
	
	call_deferred("move_to_last_position")

func move_to_last_position():
	#move to last position in chierarchy
	var parent = get_parent()
	var child_count = parent.get_child_count()
	parent.move_child(self, child_count-1)

func _process(_delta):
	if Input.is_action_just_pressed("toggle_inventory"):
		if is_shown: hide()
		else: show()
		is_shown = not is_shown

func show():
	$AnimationPlayer.play_backwards("out")

func hide():
	$AnimationPlayer.play("out")

func update_front():
	inv_container.update_list()
	update_cash_label()
	update_slider_max()

func update_cash_label():
	cash_label.text = "Portfel: %.1fu"% backend.cash

func update_slider_max():
	assert(current_item in inv_container.item_list)
	var maximum = inv_container.item_list[current_item]
	var price:float = trade_interface.get_price(current_item)
	slider.max_value = maximum
	slider.value = 0
	set_amount_label(0,maximum, price)
	
func set_amount_label(val, maximum, price):
	amount_label.text = "%d / %d for %1.1f\n(%1.1f)" % \
		[val,maximum, price*val, price]

func _on_inv_item_selected(item_name):
	current_item = ItemsEnum.Items[item_name]
	update_slider_max()

func _on_AmountSlider_value_changed(value):
	var maximum:int = inv_container.item_list[current_item]
	set_amount_label(value, maximum, trade_interface.get_price(current_item))

func _on_Button_pressed():
	trade_interface.sell(current_item, slider.value)
