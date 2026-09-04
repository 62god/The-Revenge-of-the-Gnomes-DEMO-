extends Area2D

@onready var player: CharacterBody2D = $"../Player"



var interactable = false

func _on_body_entered(body: Node2D) -> void:
	interactable = true
	
func _on_body_exited(body: Node2D) -> void:
	interactable = false



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Use") and interactable == true:
		player.increase_health(get_child(-1).get_health())
		queue_free()
			
