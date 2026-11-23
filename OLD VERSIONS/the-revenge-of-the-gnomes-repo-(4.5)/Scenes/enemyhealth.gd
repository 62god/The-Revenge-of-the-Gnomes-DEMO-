extends Area2D

var health = 6.0

@onready var enemy_health_label: RichTextLabel = $"../CanvasLayer/BattleUI/EnemyHealthLabel"
@onready var sword: Sprite2D = $"../CanvasLayer/BattleUI/Sword"
@onready var shield: Sprite2D = $"../CanvasLayer/BattleUI/Shield"
@onready var playerHealth: CharacterBody2D = $"../Player"
@onready var battle_ui: ColorRect = $"../CanvasLayer/BattleUI"
@onready var the_manager: Node = $"../THE_MANAGER"

var wait = false
var attack = true
var encountered = false

func Take_Damage(damage: float) -> void:
	health = health - damage
	enemy_health_label.text = "Enemy: " + str(health)
	if health <= 0:
		print("ENEMEY IS Resting in piss")
		battle_ui.endbattle()
		queue_free()
		
var player_damage: float = 3
var max_enemy_damage: float = 3

func getdamage(enemy_distance):
	var damage_multiplier: float = 0.0

	if enemy_distance <= 50.0:
		damage_multiplier = 1.0    # Gold Zone (100%)
		print("GOLD HIT!")
	elif enemy_distance <= 250.0:
		damage_multiplier = 0.5    # Silver Zone (50%)
		print("SILVER HIT!")
	elif enemy_distance <= 450.0:
		damage_multiplier = 0.25   # Bronze Zone (25%)
		print("BRONZE HIT!")
	else:
		damage_multiplier = 0.0    # Missed completely (0%)
		print("MISSED ZONES!")
	var final_damage = 0
	
	player_damage = the_manager.get_damage()
	# 4. Calculate final damage
	if (attack == true):
		final_damage = player_damage * damage_multiplier
		attack = false
		return final_damage
	else:
		final_damage = max_enemy_damage - (max_enemy_damage * damage_multiplier)
		attack= true
		return final_damage

func _process(delta: float) -> void:
	if encountered == false:
		return	
	if Input.is_action_just_pressed("ui_accept"):
		battle_ui.stopBar()
		if(battle_ui.isattacking() == false):
			return
		if wait == true:
			return
				
		if (attack == true):
			var damage = getdamage(battle_ui.getBarPosition());
			
			print(damage)
			Take_Damage(damage)
			attack = false
			wait = true
			await get_tree().create_timer(0.5).timeout
			wait = false
			shield.show()
			sword.hide()
			battle_ui.defense_mode()
		else:
			var damage = getdamage(battle_ui.getBarPosition());
			playerHealth.take_damage(damage)
			attack = true
			wait = true
			await get_tree().create_timer(0.5).timeout
			wait = false
			shield.hide()
			sword.show()
			battle_ui.attack_mode()
			
func _on_ready() -> void:
	resetstats()

func resetstats():
	shield.hide()
	sword.show()
	enemy_health_label.text = "Enemy: " + str(health)
	battle_ui.attack_mode()
	print("restarting")

func _ready():
	add_to_group("saveable")


func get_save_data():

	return {
		"type":"enemy",
		"scene":scene_file_path,
		"position":global_position,
		"health":health
	}


func _on_body_entered(body: Node2D) -> void:
	resetstats()
	encountered = true
