extends Button


func _on_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_node.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://Scenes/main_node.tscn")
	
	
