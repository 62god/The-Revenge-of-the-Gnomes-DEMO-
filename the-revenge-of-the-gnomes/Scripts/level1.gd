extends Node2D

func _enter_tree():
	# Only move the player if the switch is ON
	if Checkpoint.activated == true:
		$Player.global_position = Checkpoint.last_position
