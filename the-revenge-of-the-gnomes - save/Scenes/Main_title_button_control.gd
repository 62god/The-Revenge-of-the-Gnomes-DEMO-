extends Control

func Start_button() -> void:
	get_tree().change_scene_to_file("res://Scenes/Load_Save.tscn")

func _on_quit_button_pressed() -> void :
	get_tree().quit()
