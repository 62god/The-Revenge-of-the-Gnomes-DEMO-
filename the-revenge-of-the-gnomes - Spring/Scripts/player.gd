
extends CharacterBody2D

# ==========================================
# MOVEMENT SETTINGS
# ==========================================

var inGUI: bool = false
var SPEED: float = 75.0

@export var acceleration: float = 1200.0
@export var deceleration: float = 1600.0
@export var air_acceleration: float = 600.0
@export var air_deceleration: float = 250.0
@export var turn_acceleration: float = 1800.0
# ==========================================
# JUMP SQUASH AND STRETCH
# ==========================================

@export var jump_stretch_y: float = 1.25
@export var jump_stretch_x: float = 0.85

@export var land_squash_x: float = 1.25
@export var land_squash_y: float = 0.75

@export var stretch_recovery_speed: float = 12.0

var default_sprite_scale: Vector2
const JUMP_VELOCITY: float = -300.0
const JUMP_PAD_HEIGHT: float = -500.0

# Celeste-style jump assistance
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.12
@export var jump_cut_multiplier: float = 0.5
 
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# ==========================================
# DASH SETTINGS
# ==========================================

@export var dash_object: PackedScene
@export var dash_speed: float = 400.0
@export var dash_length: float = 0.2

const DASH_COOLDOWN: float = .3

var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO
var dash_cooldown_timer: float = 0.0

@onready var timer: Timer = $Timer
@onready var dash_timer: Timer = $DashTimer
@onready var dash_particles: GPUParticles2D = $DashParticles

@onready var player_health_label: RichTextLabel = \
	$"../CanvasLayer/BattleUI/PlayerHealthLabel"

@onready var battle_ui: ColorRect = \
	$"../CanvasLayer/BattleUI"

# ==========================================
# PLAYER STATE
# ==========================================

var jumpcount: int = 0
var isgrounded: bool = true
var isCrouching: bool = false
var swinging: bool = false

@onready var hitbox: CollisionShape2D = $Hitbox
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var double_jump: AudioStreamPlayer2D = $DoubleJump

const DUST = preload("uid://cedim0el5ndt2")

# ==========================================
# HEALTH
# ==========================================

var health: float = 3.0
var max_health: float = 3.0

# ==========================================
# FLOWERS
# ==========================================

var flowers: int = 0


# ==========================================
# GUI MOVEMENT CONTROL
# ==========================================

func pauseMovement() -> void:
	inGUI = true


func resumeMovement() -> void:
	inGUI = false


# ==========================================
# CONTROLLER DETECTION
# ==========================================



	
func is_controller() -> bool:
	var joy_axis_x := Input.get_joy_axis(
		0,
		JOY_AXIS_LEFT_X
	)

	var joy_axis_y := Input.get_joy_axis(
		0,
		JOY_AXIS_LEFT_Y
	)

	return abs(joy_axis_x) > 0.2 or abs(joy_axis_y) > 0.2


func get_direction_from_input() -> Vector2:
	if is_controller():
		var joy_dir := Vector2(
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		)

		if joy_dir.length() > 0.2:
			return joy_dir.normalized()

	var input_dir := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	if input_dir != Vector2.ZERO:
		return input_dir.normalized()

	if animated_sprite_2d.flip_h:
		return Vector2(-1.0, 0.0)

	return Vector2(1.0, 0.0)


# ==========================================
# DASH TIMER
# ==========================================

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	dash_cooldown_timer = DASH_COOLDOWN


# ==========================================
# DASH LOGIC
# ==========================================

func handle_dash(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if can_dash and Input.is_action_just_pressed("Dash"):
		is_dashing = true
		can_dash = false

		dash_direction = (
			get_global_mouse_position() - global_position
		).normalized()

		# Prevent a zero-length dash direction.
		if dash_direction == Vector2.ZERO:
			dash_direction = Vector2.RIGHT

		dash_timer.start(dash_length)

	if is_dashing:
		if dash_object:
			var sprite_instance = dash_object.instantiate()
			sprite_instance.global_position = global_position
			get_parent().add_child(sprite_instance)

		dash_particles.emitting = true
	else:
		dash_particles.emitting = false

	if not is_dashing and dash_cooldown_timer <= 0.0:
		if is_on_floor() or is_on_wall():
			can_dash = true


# ==========================================
# PHYSICS PROCESS
# ==========================================

func _physics_process(delta: float) -> void:

	# Battle UI blocks movement.
	if battle_ui and battle_ui.isattacking():
		return

	# GUI blocks movement.
	if inGUI:
		return

	# ==========================================
	# DASH
	# ==========================================

	handle_dash(delta)

	if is_dashing:
		Level1.shake(1, 0.2)
		velocity = dash_direction * dash_speed
		move_and_slide()
		return

	# ==========================================
	# LANDING DUST
	# ==========================================

	if not isgrounded and is_on_floor():
		var instance = DUST.instantiate()
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)

		play_land_squash()
		

	isgrounded = is_on_floor()

	# ==========================================
	# COYOTE TIME
	# ==========================================

	if is_on_floor():
		coyote_timer = coyote_time
		jumpcount = 0
	else:
		coyote_timer = maxf(
			coyote_timer - delta,
			0.0
		)

	# ==========================================
	# JUMP BUFFER
	# ==========================================

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(
			jump_buffer_timer - delta,
			0.0
		)

	# ==========================================
	# GRAVITY
	# ==========================================

	if not is_on_floor():
		velocity += get_gravity() * delta

	# ==========================================
	# JUMP AND DOUBLE JUMP
	# ==========================================

	if jump_buffer_timer > 0.0:
		if is_on_floor() or coyote_timer > 0.0 or jumpcount < 2:

			jumpcount += 1
			velocity.y = JUMP_VELOCITY
			Level1.shake(.5, .2)
			play_jump_stretch()
			jump_buffer_timer = 0.0
			coyote_timer = 0.0

			if jumpcount == 1:
				sound.play()
			elif jumpcount == 2:
				double_jump.play()

	# ==========================================
	# VARIABLE JUMP HEIGHT
	# ==========================================

	if Input.is_action_just_released("ui_accept"):
		if velocity.y < 0.0:
			velocity.y *= jump_cut_multiplier

	# ==========================================
	# MOVEMENT INPUT
	# ==========================================

	var movement_direction := Input.get_axis(
		"ui_left",
		"ui_right"
	)

	# ==========================================
	# FLIP PLAYER
	# ==========================================

	if movement_direction > 0.0:
		animated_sprite_2d.flip_h = false
	elif movement_direction < 0.0:
		animated_sprite_2d.flip_h = true

	# ==========================================
	# SWING
	# ==========================================

	if Input.is_action_just_pressed("Swing"):
		if not swinging:
			Level1.shake(2,.1)
			isCrouching = false
			swinging = true
			animated_sprite_2d.play("swing")

	# ==========================================
	# NORMAL ANIMATION
	# ==========================================

	if not swinging:
		if is_on_floor():
			if movement_direction == 0.0:
				animated_sprite_2d.play("Idle")
			elif not isCrouching:
				animated_sprite_2d.play("run")
			else:
				animated_sprite_2d.play("crouching_run")
		else:
			isCrouching = false
			animated_sprite_2d.play("jump")

	# ==========================================
	# CROUCH
	# ==========================================

	if not swinging:
		if Input.is_action_pressed("crouch"):
			if is_on_floor():
				isCrouching = true

				if movement_direction == 0.0:
					animated_sprite_2d.play("crouch")
				else:
					animated_sprite_2d.play("crouching_run")
		else:
			isCrouching = false

	# ==========================================
	# CROUCH SPEED AND HITBOX
	# ==========================================

	if isCrouching:
		SPEED = 45.0
		hitbox.set_deferred("disabled", true)
	else:
		SPEED = 75.0
		hitbox.set_deferred("disabled", false)

	# ==========================================
	# CROUCH DROP
	# ==========================================

	if Input.is_action_just_pressed("crouch") and jumpcount > 0:
		velocity.y = 500.0

	# ==========================================
	# CELESTE-STYLE HORIZONTAL MOVEMENT
	# ==========================================

	var target_speed: float = movement_direction * SPEED
	var current_acceleration: float

	if movement_direction != 0.0:
		if is_on_floor():
			current_acceleration = acceleration
		else:
			current_acceleration = air_acceleration

		# Quickly reverse direction when pressing
		# the opposite movement key.
		if (
			sign(velocity.x) != sign(movement_direction)
			and abs(velocity.x) > 1.0
		):
			current_acceleration = turn_acceleration

		velocity.x = move_toward(
			velocity.x,
			target_speed,
			current_acceleration * delta
		)
	else:
		if is_on_floor():
			current_acceleration = deceleration
		else:
			current_acceleration = air_deceleration

		velocity.x = move_toward(
			velocity.x,
			0.0,
			current_acceleration * delta
		)

	# ==========================================
	# APPLY MOVEMENT
	# ==========================================

	move_and_slide()
	# Smoothly return sprite to its normal scale.
	animated_sprite_2d.scale = animated_sprite_2d.scale.lerp(
		default_sprite_scale,
		clampf(stretch_recovery_speed * delta, 0.0, 1.0)
	)

# ==========================================
# SWING ANIMATION FINISHED
# ==========================================

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "swing":
		swinging = false


# ==========================================
# HEALTH FUNCTIONS
# ==========================================

func get_health() -> float:
	return health


func get_maxhealth() -> float:
	return max_health


func increase_health(amount: float) -> void:
	max_health += amount
	health = max_health

	player_health_label.text = "Player: " + str(health)


func take_damage(damage: float) -> void:
	health -= damage

	if health <= 0.0:
		health = 0.0
		player_health_label.text = "Player: " + str(health)

		print("you died")

		await get_tree().create_timer(0.1).timeout

		get_tree().change_scene_to_file(
			"res://Scenes/ded.tscn"
		)
		return

	if health >= max_health:
		health = max_health

	player_health_label.text = "Player: " + str(health)


func _on_player_health_label_ready() -> void:
	health = max_health
	player_health_label.text = "Player: " + str(health)


# ==========================================
# FLOWERS
# ==========================================

func give_flowers(amount: int) -> void:
	flowers += amount
	print(flowers)


# ==========================================
# READY
# ==========================================

func _ready() -> void:
	add_to_group("saveable")
	
	global_position = TheManager.spawnPosition
	
	default_sprite_scale = animated_sprite_2d.scale
	dash_timer.one_shot = true

	if not dash_timer.timeout.is_connected(
		_on_dash_timer_timeout
	):
		dash_timer.timeout.connect(
			_on_dash_timer_timeout
		)

	# Custom mouse cursor.
	var cursor_texture = load(
		"res://Assets/brackeys_platformer_assets/sprites/62-3x.png"
	)

	if cursor_texture:
		Input.set_custom_mouse_cursor(
			cursor_texture,
			Input.CURSOR_ARROW,
			Vector2(4, 4)
		)

	await get_tree().process_frame

	if CheckpointManager.has_checkpoint:
		global_position = CheckpointManager.last_location
		print(
			"RESPAWNING AT: ",
			CheckpointManager.last_location
		)


# ==========================================
# SAVE SYSTEM
# ==========================================

func get_save_data() -> Dictionary:
	return {
		"type": "player",
		"position": global_position,
		"health": health,
		"flowers": flowers,
	}

func launch_from_jump_pad() -> void:
	Level1.shake(2, .2)
	play_jump_stretch()
	velocity.y = JUMP_PAD_HEIGHT
	jumpcount = 1
	coyote_timer = 0.0
	jump_buffer_timer = 0.0

# ==========================================
# JUMP STRETCH
# ==========================================

func play_jump_stretch() -> void:
	animated_sprite_2d.scale = Vector2(
		default_sprite_scale.x * jump_stretch_x,
		default_sprite_scale.y * jump_stretch_y
	)


# ==========================================
# LAND SQUASH
# ==========================================

func play_land_squash() -> void:
	animated_sprite_2d.scale = Vector2(
		default_sprite_scale.x * land_squash_x,
		default_sprite_scale.y * land_squash_y
	)
