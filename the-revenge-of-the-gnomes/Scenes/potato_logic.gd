extends Sprite2D

var health: float = 1

func get_health() -> float:
	return health
	
func _ready():
	add_to_group("saveable")
	
func get_save_data():

	return {
		"type":"consumable",
		"collected": get_parent().get_parent() != null,
		"position":global_position
	}
