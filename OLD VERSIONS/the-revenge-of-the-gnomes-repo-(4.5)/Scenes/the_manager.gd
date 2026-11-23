extends Node
@onready var esc_menu: CanvasLayer = $EscMenu


var on_off = false

var attack = 1

func update_attack(amount: float):
	attack = amount

func get_damage():
	return attack

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ESC"):
		on_off = !on_off
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

	print(save_data)


func _on_ready() -> void:
	esc_menu.visible = false


func _on_save_pressed() -> void:
	print("hi")
	var save_data = []

	for node in get_tree().get_nodes_in_group("saveable"):

		if node.has_method("get_save_data"):
			save_data.append(node.get_save_data())
	print(OS.get_user_data_dir())
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
