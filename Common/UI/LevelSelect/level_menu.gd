extends MarginContainer

const LEVEL_BUTTON = preload("res://Common/UI/LevelSelect/level_button.tscn")
const POINTER_OVERLAP := 6
const VERTICAL_OFFSET := 8

@export var top_pointer_icon: Texture2D

var left_tip_text: String = """
         [img]res://Common/Assets/Icons/finger_point_reverse.png[/img]
[img=32x32]{icon}[/img] Button for    
Easier Courses"""

var right_tip_text: String = """
            [img]res://Common/Assets/Icons/finger_point.png[/img]
[img=32x32]{icon}[/img] Button for 
Harder courses"""

var category_buttons: Array = []
var current_category_index := 0

var level_buttons: Array = []
var current_level_index := 0

var input_actions: Dictionary = {}

@onready var container_level_select: MarginContainer = $VBoxContainer/container_level_select
@onready var grid_container: GridContainer = $VBoxContainer/container_level_select/PanelContainer/GridContainer
@onready var pointer_icon: TextureRect = $VBoxContainer/container_level_select/PanelContainer/PointerIcon
@onready var button_container: VBoxContainer = $VBoxContainer/MarginContainer/button_container
@onready var left_tip_label: RichTextLabel = $VBoxContainer/HBoxContainer/LeftTipContainer/HBoxContainer/LeftTipLabel
@onready var right_tip_label: RichTextLabel = $VBoxContainer/HBoxContainer/RightTipContainer/HBoxContainer/RightTipLabel

func _ready() -> void:
	var level_database = LevelManager.level_database
	if not level_database:
		printerr("Could not find level database.")
		return
		
	var levels_array = level_database.levels_array 
	if not levels_array:
		return
	
	InputManager.input_method_changed.connect(_on_input_method_changed)
	
	pointer_icon.top_level = true
	pointer_icon.visible = false
	pointer_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for i in range(levels_array.size()):
		var level = levels_array[i]
		var level_button = LEVEL_BUTTON.instantiate()
		level_button.set_button(
			level.level_name, 
			i+1,
			level.scene
			)
		grid_container.add_child(level_button)
		level_buttons.append(level_button)

	set_inputs()
	setup_pointer_icon()
	set_input_icons(InputManager.current_input)
	select_level.call_deferred(0)

func set_inputs() -> void:
	input_actions = {
		"menu_left": switch_category.bind(-1),
		"menu_right": switch_category.bind(1),
		"ui_left": move_selector.bind(-1, 0),
		"ui_right": move_selector.bind(1, 0),
		"ui_up": move_selector.bind(0, -1),
		"ui_down": move_selector.bind(0, 1),
		"ui_accept": load_level,
		"ui_cancel": enter_main_menu,
	}

func _input(event: InputEvent) -> void:
	for action in input_actions:
		if event.is_action_pressed(action):
			input_actions[action].call()
			return

func enter_main_menu() -> void:
	get_tree().change_scene_to_file("res://Common/UI/main_menu.tscn")

func load_level() -> void:
	LevelManager.current_level = current_level_index + 1
	get_tree().change_scene_to_file("res://Stages/main.tscn")

func move_selector(dx: int, dy: int) -> void:
	if level_buttons.is_empty():
		return
		
	var columns = grid_container.columns
	
	var row = current_level_index / columns
	var col = current_level_index % columns
	
	var new_row = row + dy
	var new_col = col + dx
	
	if new_col < 0 or new_col >= columns:
		return
	if new_row < 0:
		return
	
	
	var new_index = new_row * columns + new_col
	if new_index < 0 or new_index >= level_buttons.size():
		return
	
	select_level(new_index)

func setup_pointer_icon():
	category_buttons = button_container.get_children().filter(
		func(b): return b is Button
	)
	
	for button in category_buttons:
		button.icon = top_pointer_icon
		var icon_width = int(button.size.y)
		var style = button.get_theme_stylebox("normal") as StyleBoxFlat
		if style:
			style.content_margin_right += icon_width
		set_icon_visible(button, false)
		
		if category_buttons.size() > 0:
			set_icon_visible(category_buttons[0], true)

func set_icon_visible(button: Button, is_visible: bool) -> void:
	var alpha = 1.0 if is_visible else 0.0
	var button_states = [
		"icon_normal_color", 
		"icon_hover_color", 
		"icon_pressed_color", 
		"icon_focus_color"
	]
	for state in button_states:
		button.add_theme_color_override(state, Color(1, 1, 1, alpha))

func switch_category(direction: int) -> void:
	if category_buttons.is_empty():
		return
		
	var new_index = current_category_index + direction
	if new_index < 0 or new_index >= category_buttons.size():
		return
	set_icon_visible(category_buttons[current_category_index], false)
	current_category_index = new_index
	set_icon_visible(category_buttons[current_category_index], true)
	category_buttons[current_category_index].grab_focus()

func _on_input_method_changed(input: InputManager.InputMethod) -> void:
	set_input_icons(input)

func set_input_icons(input: InputManager.InputMethod) -> void:
	if input == InputManager.InputMethod.MKB:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		change_label(
			left_tip_label, left_tip_text, InputManager.get_icon("MKB_Q")
		)
		change_label(
			right_tip_label, right_tip_text, InputManager.get_icon("MKB_E")
		)
	elif input == InputManager.InputMethod.CONTROLLER:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		change_label(
			left_tip_label, left_tip_text, InputManager.get_icon("CONT_LB")
		)
		change_label(
			right_tip_label, right_tip_text, InputManager.get_icon("CONT_RB")
		)

func change_label(label: RichTextLabel, text: String, icon: String) -> void:
	label.text = text.format({
		"icon": icon
	})

func select_level(index: int) -> void:
	if level_buttons.is_empty():
		return
	current_level_index = index
	position_level_pointer(level_buttons[index])

func position_level_pointer(button: Button) -> void:
	pointer_icon.visible = true
	var target_x = (
		button.global_position.x - pointer_icon.size.x + POINTER_OVERLAP
	)
	pointer_icon.global_position = Vector2(
		target_x, button.global_position.y + 
		(button.size.y - pointer_icon.size.y) / 2.0 - VERTICAL_OFFSET
	)
