extends ColorRect

@onready var bar: Panel = $Bar

func hide_ui():
	visible = false
	


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	visible = true
	battling = true
	
	
	

@export var start_position: Vector2 = Vector2(172.188, 62.813)
@export var end_position: Vector2 = Vector2(977.909, 62.813)
@export var speed: float = 1.3 # Higher = faster

var progress: float = 0.0
var moving_forward: bool = true
var battling: bool = false

var enemy
var attack = true
var restartbar = false

func endbattle():
	hide_ui()
	attack = false
	battling = false

func isattacking()->bool:
	return battling

func defense_mode():
	bar.global_position = start_position
	speed = 1.3
	restartbar = true
	
func attack_mode():
	bar.global_position = start_position
	speed = 1.3
	restartbar = true
	
	
func stopBar():
	speed = 0
func _process(delta: float) -> void:
	
	if(!battling):
		return
	if moving_forward:
		progress += delta * speed
		if progress >= 1.0:
			progress = 1.0
			moving_forward = false # Switch direction
	else:
		progress -= delta * speed
		if progress <= 0.0:
			progress = 0.0
			moving_forward = true # Switch direction
	if (restartbar == true):
		progress = 0.0
		restartbar = false
	# Linearly interpolate between the two points
	bar.global_position = start_position.lerp(end_position, progress)
	
	# Tiered zone calculation

func getBarPosition() -> float:
	if(!battling):
		return 0
	# 1. Find the middle point of the track
	var middle_point: Vector2 = start_position.lerp(end_position, 0.5)
	
	# 2. Get the enemy's absolute distance from that middle point
	var enemy_distance: float = bar.global_position.distance_to(middle_point)
	
	# 3. Determine damage multiplier based on 50px step zones
	return enemy_distance
	# 5. Apply damage to the enemy
	# if final_damage > 0.0 and enemy.has_method("take_damage"):
	#	enemy.take_damage(final_damage)
