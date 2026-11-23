extends Sprite2D

var value = 3
var size = 1
func get_value():
	return value
	
func get_size():
	return size

func _ready():
	add_to_group("saveable")
	
func get_save_data():

	return {
		"type":"trash",
		"collected": get_parent().get_parent() != null,
		"position":global_position
	}
