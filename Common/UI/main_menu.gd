extends MarginContainer

@export var pointer_icon: Texture2D

enum InputMethod { MOUSE, KEYBOARD_CONTROLLER }
var current_input_method := InputMethod.MOUSE

@onready var button_container: VBoxContainer = $HBoxContainer/MarginContainer/button_container
@onready var level_select_button: Button = $HBoxContainer/MarginContainer/button_container/level_select_button
@onready var versus_button: Button = $HBoxContainer/MarginContainer/button_container/versus_button
@onready var level_editor_button: Button = $HBoxContainer/MarginContainer/button_container/level_editor_button

func _ready() -> void:
	setup_icons()
	InputManager.input_method_changed.connect(_on_input_method_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		current_input_method = InputMethod.MOUSE
		_check_hover_focus()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") \
		or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") \
		or event.is_action_pressed("ui_accept"):
		current_input_method = InputMethod.KEYBOARD_CONTROLLER

func setup_icons() -> void:
	for button in button_container.get_children():
		if button is not Button:
			continue
		button.focus_entered.connect(_on_button_focused.bind(button))
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.icon = pointer_icon
		var icon_width = int(button.size.y)  # matches your icon_max_width value
		var style = button.get_theme_stylebox("normal") as StyleBoxFlat
		if style:
			style.content_margin_right += icon_width
		button.add_theme_color_override(
			"icon_normal_color", Color(1, 1, 1, 0)
		)
	# Default focus on first button
	button_container.get_child(0).grab_focus()

func _check_hover_focus():
	for button in button_container.get_children():
		if button is Button and button.get_global_rect().has_point(
			get_global_mouse_position()
		):
			button.grab_focus()
			return

func _on_button_mouse_entered(button: Button):
	if current_input_method == InputMethod.MOUSE:
		button.grab_focus()
		
func _on_button_focused(button: Button):
	for other_button in button_container.get_children():
		if other_button is Button:
			other_button.add_theme_color_override("icon_normal_color", Color(1, 1, 1, 0))
	button.add_theme_color_override("icon_normal_color", Color(1, 1, 1, 1))

func _on_input_method_changed(input: InputManager.InputMethod) -> void:
	if input == InputManager.InputMethod.MKB:
		enable_mouse_interaction()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif input == InputManager.InputMethod.CONTROLLER:
		disable_mouse_interaction()
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func disable_mouse_interaction() -> void:
	for button in button_container.get_children():
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func enable_mouse_interaction() -> void:
	for button in button_container.get_children():
		button.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_level_select_button_pressed() -> void:
	# load level selector
	get_tree().change_scene_to_file("res://Common/UI/LevelSelect/level_menu.tscn")
