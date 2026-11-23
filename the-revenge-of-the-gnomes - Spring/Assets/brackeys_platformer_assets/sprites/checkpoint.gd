extends Area2D

@onready var respawn_point: Marker2D = $RespawnPoint

func _on_body_entered(body: Node2D) -> void:
	print("CHECKPOINT SIGNAL FIRED")

	if body is CharacterBody2D:
		print("PLAYER DETECTED")
		CheckpointManager.set_checkpoint(respawn_point.global_position)
