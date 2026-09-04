extends Node2D

func _enter_tree():
	# Only move the player if the switch is ON
	if Checkpoint.activated == true:
		$Player.global_position = Checkpoint.last_position


func _on_ready() -> void:
			Transition.color_rect.visible = true
			Transition.animation_player.play("Start")
			await Transition.on_transition_finished
			Transition.color_rect.visible = false
