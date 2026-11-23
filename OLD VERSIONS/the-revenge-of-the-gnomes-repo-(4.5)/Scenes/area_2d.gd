extends Area2D
@onready var double_jump: AudioStreamPlayer2D = $DoubleJump
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"

func _on_body_entered(body: Node2D) -> void:
	if body.get("jump_pad_height"):
		body.velocity.y = body.jump_pad_height
		double_jump.play()
	
	if "jumpcount" in body:
		body.jumpcount = 1 
