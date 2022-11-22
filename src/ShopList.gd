extends Control

onready var shop_container:VBoxContainer = $VBoxContainer/ShopInventory/ItemList
onready var amount_label = $VBoxContainer/AmountLabel
onready var slider: HSlider = $VBoxContainer/AmountSlider
onready var button:Button = $VBoxContainer/Button

onready var trade_interface = $"/root/TradeInterface"
var current_item:int = 0

func _ready():
	set_amount_label(0,0,0)
	
	call_deferred("move_to_last_position")

func move_to_last_position():
	#move to last position in chierarchy
	var parent = get_parent()
	var child_count = parent.get_child_count()
	parent.move_child(self, child_count-1)

func shop_available(shop_inv:Node):
	set_amount_label(0,0,0)
	if shop_inv : 
		show()
		shop_container.set_item_list(shop_inv.inventory)
	else: 
		hide()
		shop_container.set_item_list(null)


func show():
	$AnimationPlayer.play_backwards("out")
	#print("minimap maximized")

func hide():
	$AnimationPlayer.play("out")
	#print("minimap minimized")
	
func set_amount_label(val, maximum, price):
	amount_label.text = "%d / %d for %1.1f\n(%1.1f)" % \
		[val,maximum, price*val, price]

func update_slider_max():
	assert(shop_container.item_list.has(current_item))
	var maximum = shop_container.item_list[current_item]
	var price:float = trade_interface.get_price(current_item)
	slider.max_value = maximum
	set_amount_label(slider.value, maximum, price)

func update_front():
	shop_container.update_list()
	update_slider_max()

func _on_ItemList_item_selected(item_name):
	current_item = ItemsEnum.Items[item_name]
	update_front()

func _on_AmountSlider_value_changed(value):
	var maximum:int = shop_container.item_list[current_item]
	var price:float = trade_interface.get_price(current_item)
	set_amount_label(value, maximum, price)

func _on_Button_pressed():
	trade_interface.buy(current_item, slider.value)





