extends Node

signal input_method_changed(input: InputMethod)

enum InputMethod { MKB, CONTROLLER }

var current_input := InputMethod.MKB
var MKB_EVENTS = [
	InputEventMouseMotion, 
	InputEventMouseButton, 
	InputEventKey
]

const ICON_MAP: Dictionary = {
	"MKB_Q": "res://Common/Assets/UI/mkb_q.tres",
	"MKB_E": "res://Common/Assets/UI/mkb_e.tres",
	"CONT_LB": "res://Common/Assets/UI/controller_lb.tres",
	"CONT_RB": "res://Common/Assets/UI/controller_rb.tres"
}

func _input(event: InputEvent) -> void:
	var new_input = current_input
	if is_event_type(event, MKB_EVENTS):
		new_input = InputMethod.MKB
	
	if event is InputEventJoypadButton:
		new_input = InputMethod.CONTROLLER
	# Check for controller drift
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.3:
			new_input = InputMethod.CONTROLLER
		
	if new_input != current_input:
		current_input = new_input
		input_method_changed.emit(current_input)

func is_event_type(event: InputEvent, types: Array) -> bool:
	for type in types:
		if is_instance_of(event, type):
			return true
	return false

func get_icon(action_key: String) -> String:
	if ICON_MAP.has(action_key):
		return ICON_MAP[action_key]
	else:
		printerr("That key isn't mapped to a resource file!")
		return ""
