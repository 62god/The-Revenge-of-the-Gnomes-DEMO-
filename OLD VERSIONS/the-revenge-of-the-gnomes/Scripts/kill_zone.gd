extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return

	print("PLAYER DIED")
	print("CHECKPOINT: ", CheckpointManager.last_location)
	print("HAS CHECKPOINT: ", CheckpointManager.has_checkpoint)

	SoundPlayer.play_death_sound()

	get_tree().change_scene_to_file("res://Scenes/ded.tscn")
