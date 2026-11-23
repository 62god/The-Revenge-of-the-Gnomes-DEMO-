extends CanvasLayer

@export_file("*.json") var scene_text_file: String

var scene_text: Dictionary = {}
var selected_text: Array = []
var in_progress: bool = false
var should_delete: bool = false

@onready var background = $Background
@onready var text_label = $TextLabel


func _ready():
	background.visible = false
	scene_text = load_scene_text()
	SignalBus.connect("display_dialog", Callable(self, "on_display_dialog"))


func load_scene_text():
	if FileAccess.file_exists(scene_text_file):
		var file = FileAccess.open(scene_text_file, FileAccess.READ)
		var test_json_conv = JSON.new()

		if test_json_conv.parse(file.get_as_text()) == OK:
			return test_json_conv.get_data()

	return {}


func show_text():
	text_label.text = selected_text.pop_front()


func next_line():
	if selected_text.size() > 0:
		show_text()
	else:
		finish()


func finish():
	text_label.text = ""
	background.visible = false
	in_progress = false
	get_tree().paused = false

	if should_delete:
		queue_free()


func on_display_dialog(text_key):
	if not scene_text.has(text_key):
		return

	if in_progress:
		next_line()
		return

	get_tree().paused = true
	background.visible = true
	in_progress = true

	should_delete = false

	selected_text = scene_text[text_key].duplicate()

	# DELETE flag
	if "DELETE" in selected_text:
		selected_text.erase("DELETE")
		should_delete = true

	# AUTO flag
	if "AUTO" in selected_text:
		selected_text.erase("AUTO")

	show_text()
