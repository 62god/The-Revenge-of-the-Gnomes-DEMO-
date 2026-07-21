extends Sprite2D

var damage = 5

func get_damage():
	return damage

func _ready():
	add_to_group("saveable")
	
func get_save_data():

	return {
		"type":"weapon",
		"collected": get_parent().get_parent() != null,
		"position":global_position
	}
