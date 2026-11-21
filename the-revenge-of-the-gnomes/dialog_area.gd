
extends Area2D

@export var text_key: String = ""
@export_file("*.json") var scene_text_file: String

var area_active: bool = false
var should_delete: bool = false
var should_auto: bool = false
var has_played: bool = false


func _ready() -> void:
	check_flags()

	if should_delete:
		queue_free()
		return

	if should_auto:
		play_dialog()


func check_flags() -> void:
	if not FileAccess.file_exists(scene_text_file):
		return

	var file = FileAccess.open(scene_text_file, FileAccess.READ)

	if file == null:
		return

	var json = JSON.new()

	if json.parse(file.get_as_text()) != OK:
		push_warning("Failed to parse dialogue JSON.")
		return

	var scene_text = json.get_data()

	if not scene_text is Dictionary:
		return

	if not scene_text.has(text_key):
		return

	var dialog_lines = scene_text[text_key]

	if dialog_lines is Array:
		should_delete = "DELETE" in dialog_lines
		should_auto = "AUTO" in dialog_lines


func play_dialog() -> void:
	if has_played:
		return

	has_played = true
	SignalBus.emit_signal("display_dialog", text_key)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Use") and area_active:
		if not should_auto:
			play_dialog()

		if should_delete:
			queue_free()


func _on_DialogArea_area_entered(area: Area2D) -> void:
	area_active = true


func _on_DialogArea_area_exited(area: Area2D) -> void:
	area_active = false
