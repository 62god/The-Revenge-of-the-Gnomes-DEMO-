extends Node

var last_location: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false

func set_checkpoint(location: Vector2) -> void:
	last_location = location
	has_checkpoint = true
	print("CHECKPOINT SAVED: ", last_location)

func clear_checkpoint() -> void:
	last_location = Vector2.ZERO
	has_checkpoint = false
