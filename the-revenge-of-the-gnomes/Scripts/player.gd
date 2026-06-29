extends CharacterBody2D


var SPEED = 75
const JUMP_VELOCITY = -300.0
const jump_pad_height = -500

var jumpcount = 0
var isgrounded = true
var isCrouching = false
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var double_jump: AudioStreamPlayer2D = $DoubleJump
const DUST = preload("uid://cedim0el5ndt2")

var time_passed: float = 0.0

#func _timer(delta: float) -> void:
#	time_passed += delta
#	
#	if time_passed >= 0.1:
#		print(jumpcount)
#		time_passed = 0.0 # Reset the clock

func _physics_process(delta: float) -> void:
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
	if is_on_floor():
		jumpcount = 0
	
	if Input.is_action_just_pressed("ui_accept") and jumpcount < 2:
		jumpcount += 1
		if jumpcount == 1:
			sound.play()
		if jumpcount == 2:
			double_jump.play()
		velocity.y = JUMP_VELOCITY
	
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	#flip
	if direction > 0:
		animated_sprite_2d.flip_h = 0
	elif direction < 0:
		animated_sprite_2d.flip_h = 1
		#animate
	if is_on_floor():
		if direction == 0:
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
					if direction == 0:
						animated_sprite_2d.play("crouch")
					else:
						animated_sprite_2d.play("crouching_run")
				
					
	else: isCrouching = false
			
	if isCrouching == true:
		SPEED = 45
		hitbox.set_deferred("disabled", true)
	else:
		SPEED = 75
		hitbox.set_deferred("disabled", false)
	
		
	if Input.is_action_just_pressed("crouch") and jumpcount > 0:
				velocity.y = 500
	
			
	
		
	if direction:
		velocity.x = direction * SPEED
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()
