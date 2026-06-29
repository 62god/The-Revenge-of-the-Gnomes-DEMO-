extends RichTextLabel

## Duration in seconds for the entire text to display
@export var duration: float = 2.0

func _ready() -> void:
	# Example text
	text = "Long ago,the Gnomes lived happily in their kingdom, but then the mergas came.
"
	start_typewriter()

func start_typewriter() -> void:
	# 1. Start with 0 characters visible
	visible_characters = 0
	
	# 2. Create a tween to animate the visible characters
	var tween = create_tween()
	
	# 3. Animate 'visible_characters' from 0 to the total number of characters
	tween.tween_property(self, "visible_characters", get_total_character_count(), duration)
	
	# Optional: Choose an transition type for a linear, steady speed
	tween.set_trans(Tween.TRANS_LINEAR)
