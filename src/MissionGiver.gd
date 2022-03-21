extends Spatial

#onready var player_inventory = $"/root/Root/InventoryList"

#export(Resource) var race_mission
#export(Resource) var barrel_mission
#export(Resource) var shooting_mission

var boat_in_proximity:bool = false

var text_pool = [
	"Witam w porcie",
	"Jestem dawaczem misji",
	"Prosze wybrac misje"
]

var text_index:int = 0
var next_text = ""
var next_text_counter:int = 0
var char_per_sec:float = 10.0
var timer:float = 0.0

#var shop_inventory = {}

#class A:
#	func f(): print("fA")
#
#class B:
#	extends A
#	func f(): print("fB")
#	func f1(): print("f1B")

#func _ready():
#	init_shop_inventory()
#	print("----------F TST----------")
#	var a:A = B.new()
#	a.f()
#	a.f1()
#	print("----------F END----------")
	
#func _process(delta):
#	#assert(player_inventory)
##	if next_text.length() > next_text_counter:
##		timer += delta
##		if timer > (1.0/char_per_sec):
##			timer = 0.0
##			next_text_counter += 1
##			$Viewport/Label.text = next_text.left(next_text_counter)
#
#	if boat_in_proximity and Input.is_action_just_pressed("action"):
#		text_index = (text_index+1)%text_pool.size()
#		next_text = text_pool[text_index]
#		next_text_counter = 0
			
#func init_shop_inventory():
#	for i in player_inventory.item_prices:
#		shop_inventory[i] = i.hash()%20

func _on_Area_body_entered(body):
	boat_in_proximity = true
	$OldClassy_Male/AnimationPlayer.play("Victory")
#	next_text = text_pool[0]
#	next_text_counter = 0
	
	#player_inventory.shop_available(shop_inventory)

func _on_Area_body_exited(body):
	boat_in_proximity = false
	#player_inventory.shop_available(null)
	
#func show_mission_icons():
#	$BarelIcon.visible = true
#	$CanonIcon.visible = true
#	$RaceIcon.visible = true
#	$BarelIcon/Mesh.scale = Vector3.ZERO
#	$CanonIcon/Mesh.scale = Vector3.ZERO
#	$RaceIcon/Mesh.scale = Vector3.ZERO
#
#	$Tween.interpolate_property($BarelIcon/Mesh,"scale", Vector3.ZERO,
#		Vector3(0.6,0.6,0.6),1)
#	$Tween.interpolate_property($CanonIcon/Mesh,"scale", Vector3.ZERO,
#		Vector3(0.6,0.6,0.6),1)
#	$Tween.interpolate_property($RaceIcon/Mesh,"scale", Vector3.ZERO,
#		Vector3(0.6,0.6,0.6),1)
#	$Tween.start()
#
#func hide_mission_icons():	
#	$Tween.interpolate_property($BarelIcon/Mesh,"scale", Vector3(0.6,0.6,0.6),
#		Vector3.ZERO,1)
#	$Tween.interpolate_property($CanonIcon/Mesh,"scale", Vector3(0.6,0.6,0.6),
#		Vector3.ZERO,1)
#	$Tween.interpolate_property($RaceIcon/Mesh,"scale", Vector3(0.6,0.6,0.6),
#		Vector3.ZERO,1)
#	$Tween.start()
#
#	yield($Tween, "tween_all_completed")
#	$BarelIcon.visible = false
#	$CanonIcon.visible = false
#	$RaceIcon.visible = false
#
#func _on_BarelIcon_selected():
#	hide_mission_icons()
#	next_text = "Wybrano misje: Barrel"
#	next_text_counter = 0
#
#func _on_CanonIcon_selected():
#	hide_mission_icons()
#	next_text = "Wybrano misje: Cannon"
#	next_text_counter = 0
#
#func _on_RaceIcon_selected():
#	hide_mission_icons()
#	next_text = "Wybrano misje: Race"
#	next_text_counter = 0
