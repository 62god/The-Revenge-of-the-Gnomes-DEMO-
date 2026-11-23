extends Node
var spawnPosition: Vector2 = Vector2.ZERO
var esc_menu: CanvasLayer = null

	
var on_off = false

var attack = 1

func changeSpawn(newlocation: Vector2):
	spawnPosition = newlocation
	print("NEW SPAWN: ", spawnPosition)
	_on_save_pressed()
func respawn():
	var player = get_tree().current_scene.get_node("Player")
	player.global_position = spawnPosition
	
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
	attack = save_data["attack"]
	print("GAME LOADED!")
	print("SPAWN: ", spawnPosition)
	respawn()
	print("ATTACK: ", attack)
func _ready() -> void:
	esc_menu = get_tree().root.find_child("EscMenu", true, false)

	if esc_menu == null:
		print("ERROR: ESC MENU NOT FOUND!")
		return
	print("ESC MENU FOUND!")
	esc_menu.visible = false
	load_game()
	
func _on_save_pressed():
	var save_data = {
		"spawn_position": {
			"x": spawnPosition.x,
			"y": spawnPosition.y
		},
		"attack": attack
		}
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	if file == null:
		print("SAVE FAILED: ", FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("SAVED SPAWN: ", spawnPosition)
