extends Control

onready var shop_container:VBoxContainer = $VBoxContainer/ShopInventory/ItemList
onready var amount_label = $VBoxContainer/AmountLabel
onready var slider: HSlider = $VBoxContainer/AmountSlider
onready var button:Button = $VBoxContainer/Button

onready var player_inv = $"/root/Root/Inventory"

var current_item:String = "Barrel"
var backend = null

func _ready():
	assert(player_inv)
	set_amount_label(0,0,0)

func shop_available(shop_inv:Node):
	set_amount_label(0,0,0)
	if shop_inv : 
		show()
		shop_container.set_item_list(shop_inv.inventory)
	else: 
		hide()
		shop_container.set_item_list(null)
	backend = shop_inv

func show():
	$AnimationPlayer.play_backwards("out")
	#print("minimap maximized")

func hide():
	$AnimationPlayer.play("out")
	#print("minimap minimized")
	
func set_amount_label(val, maximum, price):
	amount_label.text = "%d / %d for %1.1f\n(%1.1f)" % \
		[val,maximum, price*val, price]

#func update_cash_label():
#	cash_label.text = "Portfel: %.1fu"%cash

func update_slider_max():
	assert(current_item in shop_container.item_list)
	var maximum = shop_container.item_list[current_item]
	var price:float = player_inv.item_prices[current_item]
	slider.max_value = maximum
	slider.value = 0
	set_amount_label(0,maximum, price)

func update_front():
	shop_container.update_list()
	update_slider_max()

func _on_ItemList_item_selected(item_name):
	current_item = item_name
	update_front()

func _on_AmountSlider_value_changed(value):
	var maximum:int = shop_container.item_list[current_item]
	var price:float = player_inv.item_prices[current_item]
	set_amount_label(value, maximum, price)

func _on_Button_pressed():
	backend.sell(current_item, slider.value)





