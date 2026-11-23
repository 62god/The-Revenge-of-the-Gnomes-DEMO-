extends Area2D
@onready var double_jump: AudioStreamPlayer2D = $DoubleJump
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"

func _on_body_entered(body: Node2D) -> void:
	if "jumpcount" in body:
		body.jumpcount = 1 
	if body.is_in_group("saveable"):
		body.launch_from_jump_pad()
		double_jump.play()
