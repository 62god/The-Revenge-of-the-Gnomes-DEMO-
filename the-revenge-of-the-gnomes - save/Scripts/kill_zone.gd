extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return

	print("PLAYER DIED")
	
	SoundPlayer.play_death_sound()

	get_tree().change_scene_to_file("res://Scenes/ded.tscn")
