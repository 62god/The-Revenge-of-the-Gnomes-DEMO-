extends RichTextLabel

## Duration in seconds for the entire text to display
@export var duration: float = 2.0

## The file path to your main game scene
@export_file("*.tscn") var main_scene_path: String = "res://Scenes/main_node.tscn"

## A list of dialogue lines that will play in order
@export var dialogue_lines: Array[String] = [
	"Long ago, the Gnomes lived happily in their kingdom, but then the mergas came.",
	"They were not as powerful as some, but the fight still lasted a long time.",
	"[font_size=50]The Gnomes Thought they had won the Great War against the mergas, but then as they reclaimed their habitat, the mergas attacked back and used the forbidden weapon, the ancient missile.[/font_size]",
	"[font_size=75]All of the gnomes died, All except for one, The king of the gnomes.[/font_size]",
	"Now, it's time to get your revenge"
]

var current_line_index: int = 0
var current_tween: Tween 
var original_x_position: float # Remembers where your UI label originally sits

func _ready() -> void:
	bbcode_enabled = true 
	original_x_position = position.x # Save the original layout position
	
	if dialogue_lines.size() > 0:
		display_current_line()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		advance_dialogue()

func display_current_line() -> void:
	# Checks if this is the 3rd line (Index 2) OR the 4th line (Index 3)
	if current_line_index == 2 or current_line_index == 3:
		position.x = original_x_position - 45.0 # Shifts both lines left 45px
	else:
		position.x = original_x_position # Still resets back to normal for lines 1, 2, and 5!

	text = dialogue_lines[current_line_index]
	start_typewriter()

func advance_dialogue() -> void:
	current_line_index += 1
	
	if current_line_index < dialogue_lines.size():
		display_current_line()
	else:
		if main_scene_path != "":
			get_tree().change_scene_to_file(main_scene_path)
		else:
			print("Error: main_scene_path is empty!")

func start_typewriter() -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	visible_characters = 0
	
	current_tween = create_tween()
	current_tween.tween_property(self, "visible_characters", get_total_character_count(), duration)
	current_tween.set_trans(Tween.TRANS_LINEAR)
