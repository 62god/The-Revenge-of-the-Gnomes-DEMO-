extends Sprite2D

func _physics_process(delta: float) -> void:
	# Ensure all numbers passed to lerp are floats (e.g., 0.0 instead of 0)
	modulate.a = lerp(modulate.a, 0.0, delta * 15.0)
	
	if modulate.a <= 0.05:
		queue_free()
