extends Sprite2D

var health = 1

func get_health():
	return health


func _ready():
	add_to_group("saveable")
	
func get_save_data():

	return {
		"type":"health",
		"collected": get_parent().get_parent() != null,
		"position":global_position
	}
