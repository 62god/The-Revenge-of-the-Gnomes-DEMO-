extends Node

var player : AudioStreamPlayer

func _ready():
	# Create the player node
	player = AudioStreamPlayer.new()
	add_child(player)
	
	# IMPORTANT: Change "res://death_sound.wav" to your actual file path!
	# Tip: Right-click your sound in the FileSystem dock and select "Copy Path"
	var sound = load("res://Assets/brackeys_platformer_assets/sounds/hurt.wav") 
	
	if sound:
		player.stream = sound
	else:
		push_error("AudioManager: Could not find the sound file!")

func play_death_sound():
	if player and player.stream:
		player.play()
