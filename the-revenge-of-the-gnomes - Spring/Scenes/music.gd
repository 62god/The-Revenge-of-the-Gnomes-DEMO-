extends AudioStreamPlayer2D

func _ready() -> void:
	# This automatically replays the audio every time it finishes
	finished.connect(play)
	play()
