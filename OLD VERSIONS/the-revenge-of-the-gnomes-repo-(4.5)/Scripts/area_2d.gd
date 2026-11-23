extends Area2D



func _on_body_entered(body):
	print("bruh")
	Checkpoint.last_position = global_position
	Checkpoint.activated = true # Flip the switch!
