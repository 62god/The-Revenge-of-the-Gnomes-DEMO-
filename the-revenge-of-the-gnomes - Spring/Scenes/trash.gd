extends Area2D

@onready var Item_ui: CanvasLayer = $FoodUI
@onready var player: CharacterBody2D = $"../Player"
@onready var backpack: CanvasLayer = $"../Backpack"



var interactable = false
var seen = false
var Empty = false

func _on_body_entered(body: Node2D) -> void:
	interactable = true
	
func _on_body_exited(body: Node2D) -> void:
	interactable = false



func _process(delta: float) -> void:
	if Empty == true:
		return
		
	if Input.is_action_just_pressed("Use") and interactable == true and seen == false:
		print("chest opened")
		Item_ui.show()
		seen = true
		player.pauseMovement()
		backpack.addtrash(self.get_child(-1))
	if Input.is_action_just_pressed("Backpack") and interactable == true:
		Item_ui.hide()
		seen = false
		Empty = true
		
	if Input.is_action_just_pressed("ui_accept") and seen == true:
		Item_ui.hide()
		player.resumeMovement()
		Empty = true


func _on_ready() -> void:
	Item_ui.hide()
