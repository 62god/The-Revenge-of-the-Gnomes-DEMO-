extends CharacterBody2D

var health = 3
@onready var player_health_label: RichTextLabel = $"../../CanvasLayer/BattleUI/PlayerHealthLabel"

func take_damage(damage: float):
	health = health - damage
	player_health_label.text = "Player: " + str(health)
	if health <= 0:
		print("you died")
	

func _on_ready() -> void:
	player_health_label.text = "Player: " + str(health)
