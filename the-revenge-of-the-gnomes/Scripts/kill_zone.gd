extends Area2D





func _on_body_entered(_body):
	print("bodyENtered")
	# This now refers to the Global Singleton you just registered
	SoundPlayer.play_death_sound()
	
	# Restarts instantly
	get_tree().reload_current_scene()
