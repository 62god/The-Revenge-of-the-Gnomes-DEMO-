extends Area2D
@onready var double_jump: AudioStreamPlayer2D = $DoubleJump
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"

@export var spring_type: int = 1

func _on_body_entered(body: Node2D) -> void:
	if "jumpcount" in body:
		body.jumpcount = 1 
	if body.is_in_group("saveable"):
		if spring_type == 1:
			body.launch_from_jump_pad(self)
			double_jump.play()
		elif spring_type == 2:
			body.launch_from_super_jump_pad(self)
			double_jump.play()
		elif spring_type == 3:
			body.launch_from_super_super_jump_pad(self)
			double_jump.play()
