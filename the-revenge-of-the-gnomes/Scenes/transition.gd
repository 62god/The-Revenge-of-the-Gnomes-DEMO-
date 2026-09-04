extends CanvasLayer

signal on_transition_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# Crucial: This ensures this script runs even when the game is frozen!
	process_mode = PROCESS_MODE_ALWAYS 
	
func _on_animation_finished(anim_name):
	if anim_name == "Fade_to_black":
		on_transition_finished.emit()
		animation_player.play("Fade_to_clear")
	elif anim_name == "Fade_to_clear":
		color_rect.visible = false
		# 2. UNPAUSE GAME: Everything moves normally again
		get_tree().paused = false
			
func transition():
	# 1. PAUSE GAME: Freezes player processing, animations, and all inputs
	get_tree().paused = true
	
	color_rect.visible = true
	animation_player.play("Fade_to_black")

	color_rect.visible = true
	animation_player.play("Fade_to_black")
