extends Node2D


func _on_ready() -> void:
			Transition.color_rect.visible = true
			Transition.animation_player.play("Start")
			await Transition.on_transition_finished
			Transition.color_rect.visible = false

# ==========================================
# SCREEN SHAKE
# ==========================================

var _shake_camera: Camera2D
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0
var _shake_elapsed: float = 0.0
var _shake_base_offset: Vector2 = Vector2.ZERO


func shake(strength: float, amount: float) -> void:
	if strength <= 0.0 or amount <= 0.0:
		return

	var camera := get_viewport().get_camera_2d()

	if camera == null:
		push_warning("Screen shake: No active Camera2D found.")
		return

	# Save the camera's original offset.
	if _shake_camera != camera:
		if is_instance_valid(_shake_camera):
			_shake_camera.offset = _shake_base_offset

		_shake_camera = camera
		_shake_base_offset = camera.offset

	# Allow repeated shakes to refresh or intensify.
	_shake_strength = maxf(_shake_strength, strength)
	_shake_duration = maxf(_shake_duration, amount)
	_shake_elapsed = 0.0


func _process(delta: float) -> void:
	if not is_instance_valid(_shake_camera):
		_shake_camera = null
		return

	if _shake_duration <= 0.0:
		return

	_shake_elapsed += delta

	var progress: float = clampf(
		_shake_elapsed / _shake_duration,
		0.0,
		1.0
	)

	# Fade the shake out smoothly.
	var current_strength: float = (
		_shake_strength * (1.0 - progress)
	)

	_shake_camera.offset = _shake_base_offset + Vector2(
		randf_range(-current_strength, current_strength),
		randf_range(-current_strength, current_strength)
	)

	if _shake_elapsed >= _shake_duration:
		_shake_camera.offset = _shake_base_offset

		_shake_strength = 0.0
		_shake_duration = 0.0
		_shake_elapsed = 0.0
