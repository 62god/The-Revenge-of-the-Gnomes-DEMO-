extends CanvasLayer
@onready var player: CharacterBody2D = $"../Player"
@onready var trash_slots: Control = $TrashSlots
@onready var food_slots: Control = $FoodSlots
@onready var weapon_slots: Control = $WeaponSlots

var weapons: Array [Sprite2D] = []
var foods: Array [Sprite2D] = []
var garbage: Array [Sprite2D] = []

func update_ui():
	weapon_slots.clear_slots()
	
	for w in weapons:
		var panel = weapon_slots.get_available()
		
		panel.add_child(w)
		w.position.x = 33.0
		w.position.y = 31.0
		print(panel.get_child_count())
	food_slots.clear_slots()
	
	for f in foods:
		var panel = food_slots.get_available()
		
		panel.add_child(f)
		f.position.x = 33.0
		f.position.y = 31.0
		f.scale.x = 0.115
		f.scale.y = 0.115
		print(panel.get_child_count())
		
	for t in garbage:
		var panel = trash_slots.get_available()
		
		panel.add_child(t)
		t.position.x = 33.0
		t.position.y = 31.0
		
		t.scale.x = t.get_size()
		t.scale.y = t.get_size()
		print(panel.get_child_count())
		
func addweapon(weapon: Sprite2D):
	weapons.append(weapon)
	for w in weapons:
		print(w.name)
	if(weapon.get_parent() != null):
		weapon.get_parent().remove_child(weapon)
	update_ui()
	
func addfood(food: Sprite2D):
	foods.append(food)
	for f in foods:
		print(f.name)
	if(food.get_parent() != null):
		food.get_parent().remove_child(food)
	update_ui()
	
func addtrash(trash: Sprite2D):
	garbage.append(trash)
	for t in garbage:
		print(t.name)
	if(trash.get_parent() != null):
		trash.get_parent().remove_child(trash)
	update_ui()
	
	
var Open = false
@onready var staff: Sprite2D = $"../Player/Staff"



func _on_ready() -> void:
	visible = Open
	addweapon(staff)
	var damage = staff.get_damage()
	the_manager.update_attack(damage)

var shopping = false
func shoppingMode():
	toggleBackpack(true)
	shopping = true
func endShoppingMode():
	shopping=false
	toggleBackpack()

func toggleBackpack(force = false):
	if(shopping==true):
		return
	if(force):
		Open = true
	else:
		Open = !Open
	visible = Open
	if Open == true:
		player.pauseMovement()
	else:
		player.resumeMovement()
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Backpack"):
		toggleBackpack()
			
			
@onready var selector: Panel = $selector
@onready var the_manager: Node = $"../THE_MANAGER"

	
func get_save_data():

	return {
		"type":"inventory",
		"weapons": weapons,
		"food":foods,
		"garbage":garbage
	}

func _ready():
	add_to_group("saveable")
	for group in [weapon_slots]:
		for slot in group.get_children():
			slot.slot_clicked.connect(_on_slot_clicked)
	for group in [food_slots]:
		for slot in group.get_children():
			slot.food_slot_clicked.connect(_on_food_slot_clicked)
			
	for group in [trash_slots]:
		for slot in group.get_children():
			slot.trash_slot_clicked.connect(_on_trash_slot_clicked)
			
					
func _on_slot_clicked(slot: Panel):
	if(shopping):
		return
	var damage = slot.get_child(0).get_damage()
	the_manager.update_attack(damage)
	
	selector.global_position = slot.global_position + Vector2(-5, -5)
	
func _on_food_slot_clicked(slot: Panel):
	if(shopping):
		return
	var health = slot.get_child(0).get_health()
	if (health + player.get_health() == player.get_maxhealth()):
		return
		
	player.take_damage(health * -1)
	slot.get_child(0).queue_free()
	#the_manager.update_attack(damage)


func _on_trash_slot_clicked(slot: Panel):
	#
	var value = slot.get_child(0).get_value()	
	if(shopping == true):
		player.give_flowers(value)
		slot.get_child(0).queue_free()
		
	#player.take_damage(health * -1)
	#slot.get_child(0).queue_free()
	#the_manager.update_attack(damage)
