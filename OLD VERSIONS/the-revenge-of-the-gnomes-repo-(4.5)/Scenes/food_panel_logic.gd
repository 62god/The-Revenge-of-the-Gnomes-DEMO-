extends Panel

signal food_slot_clicked(slot)

func _gui_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		# Only selectable if an item exists
		if get_child_count() > 0:
			food_slot_clicked.emit(self)
