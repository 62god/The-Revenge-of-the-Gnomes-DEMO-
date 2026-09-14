extends CharacterBody2D

var inGUI = false
var SPEED = 75
const JUMP_VELOCITY = -300.0
const jump_pad_height = -500

# 1. Export Variables & Node References
@export var dash_object: PackedScene
@export var dash_speed: float = 400.0
@export var dash_length: float = 0.2

var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO

@onready var timer: Timer = $Timer
@onready var dash_timer: Timer = $DashTimer
@onready var dash_particles: GPUParticles2D = $DashParticles
@onready var player_health_label: RichTextLabel = $"../CanvasLayer/BattleUI/PlayerHealthLabel"
@onready var battle_ui: ColorRect = $"../CanvasLayer/BattleUI"


var jumpcount = 0
var isgrounded = true
var isCrouching = false
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var double_jump: AudioStreamPlayer2D = $DoubleJump
const DUST = preload("uid://cedim0el5ndt2")


# 2. Ready Function & Timer Signal Connection

const DASH_COOLDOWN = 0.10
var dash_cooldown_timer: float = 0.0

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	dash_cooldown_timer = DASH_COOLDOWN

func pauseMovement():
	inGUI = true
	
func resumeMovement():
	inGUI = false

# 3. Input & Direction Detection
func is_controller() -> bool:
	var joy_axis_x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var joy_axis_y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	return abs(joy_axis_x) > 0.2 or abs(joy_axis_y) > 0.2

func get_direction_from_input() -> Vector2:
	if is_controller():
		var joy_dir = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		)
		if joy_dir.length() > 0.2:
			return joy_dir.normalized()
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		return input_dir.normalized()
		
	return Vector2(-1, 0) if animated_sprite_2d.flip_h else Vector2(1, 0)

# 4. Handle Dash Logic & Trail/Particles Spawning
func handle_dash(_delta: float) -> void:
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= _delta

	if can_dash and Input.is_action_just_pressed("Dash"):
		is_dashing = true
		can_dash = false
		dash_direction = get_direction_from_input()
		dash_timer.start(dash_length)
	
	if is_dashing:
		var sprite_instance = dash_object.instantiate()
		sprite_instance.global_position = global_position
		get_parent().add_child(sprite_instance)
		dash_particles.emitting = true
	else:
		dash_particles.emitting = false
		
	if not is_dashing and dash_cooldown_timer <= 0 and (is_on_floor() or is_on_wall()):
		can_dash = true

# 5. Physics Process Integration
func _physics_process(delta: float) -> void:
	if battle_ui and battle_ui.isattacking():
		return
	if inGUI == true:
		return
		
	handle_dash(delta)
	
	if is_dashing:
		velocity = dash_direction * dash_speed
		move_and_slide()
		return
	
	if isgrounded == false and is_on_floor() == true:
		var instance = DUST.instantiate()
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)
		
	isgrounded = is_on_floor()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumpcount = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jumpcount < 2:
		jumpcount += 1
		if jumpcount == 1:
			sound.play()
		if jumpcount == 2:
			double_jump.play()
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var movement_direction := Input.get_axis("ui_left", "ui_right")
	
	# flip
	if movement_direction > 0:
		animated_sprite_2d.flip_h = false
	elif movement_direction < 0:
		animated_sprite_2d.flip_h = true
		
	# animate
	if is_on_floor():
		if movement_direction == 0:
			animated_sprite_2d.play("Idle")
		else: 
			if isCrouching == false:
				animated_sprite_2d.play("run")
			else:
				animated_sprite_2d.play("crouching_run")
	else:
		isCrouching = false
		animated_sprite_2d.play("jump")
		
	if Input.is_action_pressed("crouch"):
		if is_on_floor():
			isCrouching = true
			if movement_direction == 0:
				animated_sprite_2d.play("crouch")
			else:
				animated_sprite_2d.play("crouching_run")
	else: 
		isCrouching = false
			
	if isCrouching == true:
		SPEED = 45
		hitbox.set_deferred("disabled", true)
	else:
		SPEED = 75
		hitbox.set_deferred("disabled", false)
	
	if Input.is_action_just_pressed("crouch") and jumpcount > 0:
		velocity.y = 500
	
	if movement_direction:
		velocity.x = movement_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

var health = 3.0
var max_health = 3.0

func get_health():
	return health
func get_maxhealth():
	return max_health

func increase_health(amount):
	max_health += amount
	health = max_health
	player_health_label.text = "Player: " + str(health)

func take_damage(damage: float):
	health = health - damage
	if health <= 0:
		health = 0
		player_health_label.text = "Player: " + str(health)
		print("you died")
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://Scenes/ded.tscn")
	if health >= max_health:
		health = max_health
	player_health_label.text = "Player: " + str(health)

func _on_player_health_label_ready() -> void:
	health = max_health
	player_health_label.text = "Player: " + str(health)

var flowers = 0

func give_flowers(amount):
	flowers += amount
	print(flowers)
	
func _ready():
	add_to_group("saveable")
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	
func get_save_data():
	return {
		"type":"player",
		"position":global_position,
		"health":health,
		"flowers":flowers,
	}
