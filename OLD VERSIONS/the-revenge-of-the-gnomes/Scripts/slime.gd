extends Node2D

const  speed = 60
@onready var right: RayCast2D = $right
@onready var left: RayCast2D = $left

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D



var direction = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if right.is_colliding():
		direction = -1
		sprite.flip_h = 1
	if left.is_colliding():
		direction = 1
		sprite.flip_h = 0
	
	position.x += direction * speed * delta
