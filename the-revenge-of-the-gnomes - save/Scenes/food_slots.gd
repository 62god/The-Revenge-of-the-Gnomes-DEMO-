extends Control


@onready var panel_14: Panel = $Panel14
@onready var panel_15: Panel = $Panel15
@onready var panel_16: Panel = $Panel16
@onready var panel_17: Panel = $Panel17
@onready var panel_18: Panel = $Panel18
@onready var panel_19: Panel = $Panel19
@onready var panel_20: Panel = $Panel20
@onready var panel_21: Panel = $Panel21
@onready var panel_22: Panel = $Panel22
@onready var panel_23: Panel = $Panel23
@onready var panel_24: Panel = $Panel24
@onready var panel_25: Panel = $Panel25

var food: Array [Panel] = [panel_14, panel_15, panel_16, panel_17, panel_18, panel_19, panel_20, panel_21, panel_22, panel_23, panel_24, panel_25]



func clear_slots():
	for slot in get_children():
		for child in slot.get_children():
			slot.remove_child(child)
		
func get_available() -> Panel:
	for slot in get_children():
		if slot.get_child_count() == 0:
			return slot
	return null
