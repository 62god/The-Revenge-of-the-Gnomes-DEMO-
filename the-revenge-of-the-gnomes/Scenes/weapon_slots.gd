extends Node

@onready var panel_2: Panel = $Panel2
@onready var panel_3: Panel = $Panel3
@onready var panel_4: Panel = $Panel4
@onready var panel_5: Panel = $Panel5
@onready var panel_6: Panel = $Panel6
@onready var panel_7: Panel = $Panel7
@onready var panel_8: Panel = $Panel8
@onready var panel_9: Panel = $Panel9
@onready var panel_10: Panel = $Panel10
@onready var panel_11: Panel = $Panel11
@onready var panel_12: Panel = $Panel12
@onready var panel_13: Panel = $Panel13
var weapons: Array [Panel] = [panel_2, panel_3, panel_4, panel_5, panel_6, panel_7, panel_8, panel_9, panel_10, panel_11, panel_12, panel_13]


func clear_slots():
	for slot in get_children():
		for child in slot.get_children():
			slot.remove_child(child)
		
func get_available() -> Panel:
	for slot in get_children():
		if slot.get_child_count() == 0:
			return slot
	return null
