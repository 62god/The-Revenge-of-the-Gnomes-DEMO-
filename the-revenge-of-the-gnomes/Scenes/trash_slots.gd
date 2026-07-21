extends Control

@onready var panel_26: Panel = $Panel26
@onready var panel_27: Panel = $Panel27
@onready var panel_28: Panel = $Panel28
@onready var panel_29: Panel = $Panel29
@onready var panel_30: Panel = $Panel30
@onready var panel_31: Panel = $Panel31
@onready var panel_32: Panel = $Panel32
@onready var panel_33: Panel = $Panel33
@onready var panel_34: Panel = $Panel34
@onready var panel_35: Panel = $Panel35
@onready var panel_36: Panel = $Panel36
@onready var panel_37: Panel = $Panel37

var food: Array [Panel] = [panel_26, panel_27, panel_28, panel_29, panel_30, panel_31, panel_32, panel_33, panel_34, panel_35, panel_36, panel_37]



func clear_slots():
	for slot in get_children():
		for child in slot.get_children():
			slot.remove_child(child)
		
func get_available() -> Panel:
	for slot in get_children():
		if slot.get_child_count() == 0:
			return slot
	return null
