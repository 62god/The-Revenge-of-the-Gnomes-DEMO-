extends Area2D

@onready var backpack: CanvasLayer = $"../Backpack"

var interactable = false
var shopping = false
func _on_body_entered(body: Node2D) -> void:
	interactable = true

func _on_body_exited(body: Node2D) -> void:
	interactable = false
	
func _process(delta: float) -> void:
	if interactable == true:
		if Input.is_action_just_pressed("Use"):
			backpack.shoppingMode()
			shopping = true
		if Input.is_action_just_pressed("ui_accept") and shopping == true:
			backpack.endShoppingMode()
			shopping = false
			
			
			
