extends Node
var spawnPosition: Vector2 = Vector2.ZERO
var esc_menu: CanvasLayer = null
@onready var potato_sprite: Sprite2D = $"../potato2/FoodUI/Panel/potato"

	
var on_off = false
var dead_enemy = []
var attack = 1

func changeSpawn(newlocation: Vector2):
	print("BEFORE CHECKPOINT SAVE: ", dead_enemy)

	spawnPosition = newlocation

	print("AFTER CHECKPOINT SAVE: ", dead_enemy)

	_on_save_pressed()
func respawn():
	var player = get_tree().current_scene.get_node("Player")
	print("Respawn: ", spawnPosition)
	player.global_position = spawnPosition
	print("pos ", player.global_position)
func update_attack(amount: float):
	attack = amount

func get_damage():
	return attack

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ESC"):
		on_off = !on_off
		var esc_menu = get_tree().root.find_child("EscMenu", true, false)
		
		esc_menu.visible = on_off

func load_game():
	var backpack = get_tree().root.find_child("Backpack", true, false)
	print("!!! LOAD GAME CALLED !!!")
	if !FileAccess.file_exists("user://save.json"):
		print("No save file.")
		return
	var file = FileAccess.open("user://save.json", FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	file.close()
	if save_data == null:
		print("Save file is invalid.")
		return
	spawnPosition = Vector2(
		save_data["spawn_position"]["x"],
		save_data["spawn_position"]["y"]
	)
	if (save_data.has("dead_enemy")):
		print(dead_enemy)
		dead_enemy = save_data["dead_enemy"]
		print("LOADED DEAD ENEMIES: ", dead_enemy)
	else:
		print("!!! WARNING: SAVE FILE HAS NO DEAD_ENEMY KEY !!!")
		dead_enemy = []
	attack = save_data["attack"]
	print (save_data)
	if (save_data.has("weapons")):
		backpack.weapons_data.assign(save_data["weapons"])
		backpack.update_ui()
	if (save_data.has("foods")):
		backpack.foods_data.assign(save_data["foods"])
		backpack.update_load()
	if (save_data.has("garbage")):
		backpack.garbage_data.assign(save_data["garbage"])
		backpack.update_ui()
	print(backpack.foods_data)
	print("GAME LOADED!")
	print("SPAWN: ", spawnPosition)
	respawn()
	print("ATTACK: ", attack)
func _ready() -> void:
	print("MANAGER READY")
	print("DEAD ENEMIES AT START: ", dead_enemy)
	esc_menu = get_tree().root.find_child("EscMenu", true, false)

	if esc_menu == null:
		print("ERROR: ESC MENU NOT FOUND!")
		return
	print("ESC MENU FOUND!")
	esc_menu.visible = false
	load_game()
	
func _on_save_pressed():
	var backpack = get_tree().root.find_child("Backpack", true, false)
	var save_data = {
		"spawn_position": {
			"x": spawnPosition.x,
			"y": spawnPosition.y
		},
		"attack": attack,
		"dead_enemy": dead_enemy,
		"weapons": backpack.weapons_data,
		"foods": backpack.foods_data,
		"garbage": backpack.garbage_data
		}
	print(backpack.foods)
	print(dead_enemy)
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	if file == null:
		print("SAVE FAILED: ", FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("SAVED SPAWN: ", spawnPosition)

func save_enemy(enemy_id):
	if enemy_id in dead_enemy:
		return

	dead_enemy.append(enemy_id)
	print("DEAD ENEMIES: ", dead_enemy)
	_on_save_pressed()
	
	
