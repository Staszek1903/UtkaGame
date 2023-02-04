extends Control

onready var notification = $Notification
onready var panel = $Panel
onready var label = $Panel/ScrollContainer/Label
onready var scroll = $Panel/ScrollContainer
onready var indicator = $Panel/Indicator

func add_content(val: String):
	label.text += "\n------------------------\n"
	label.text += val + "\n"
	
	
	if not panel.visible:
		notification.visible = true
		
	call_deferred("scroll_down")
		

func _process(_delta):
	indicator.visible =  scroll.scroll_vertical \
		 < max(0, label.rect_size.y - scroll.rect_size.y)

func _input(event):
	if event is InputEventKey and event.scancode == KEY_TAB and event.pressed:
		notification.visible = false
		panel.visible = not panel.visible
		call_deferred("scroll_down")
	elif event is InputEventKey and event.scancode == KEY_Y and event.pressed:
		add_content("DUPA: pierdol sie")

func scroll_down():
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	scroll.scroll_vertical = max(0, label.rect_size.y - scroll.rect_size.y)
	print("SCROLL: ", scroll.scroll_vertical)

