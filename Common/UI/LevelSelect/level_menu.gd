extends MarginContainer

const LEVEL_BUTTON = preload("res://Common/UI/LevelSelect/level_button.tscn")
const POINTER_OVERLAP := 4
const VERTICAL_OFFSET := 4

@export var pointer_texture: Texture2D = preload(
	"res://Common/Assets/Icons/finger_point.png"
)

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
var levels_by_category: Dictionary = {}
var current_level_index := 0
var input_actions: Dictionary = {}

var is_switching_categories := false

@onready var category_containers: Dictionary = {
	LevelData.Category.BEGINNERS_TEST: $VBoxContainer/category_container/container_level_select,
	LevelData.Category.WARMING_UP: $VBoxContainer/category_container/container_level_select2,
	LevelData.Category.TRICKY: $VBoxContainer/category_container/container_level_select3,
	LevelData.Category.CHALLENGING: $VBoxContainer/category_container/container_level_select4,
	LevelData.Category.ELEGANT: $VBoxContainer/category_container/container_level_select5,
	LevelData.Category.DIFFICULT: $VBoxContainer/category_container/container_level_select6,
}
@onready var category_pointers: Dictionary = {}
@onready var button_container: VBoxContainer = $VBoxContainer/MarginContainer/button_container
@onready var left_tip_label: RichTextLabel = $VBoxContainer/HBoxContainer/LeftTipContainer/HBoxContainer/LeftTipLabel
@onready var right_tip_label: RichTextLabel = $VBoxContainer/HBoxContainer/RightTipContainer/HBoxContainer/RightTipLabel
@onready var level_pointer_icon: TextureRect = $LevelPointerIcon

func _ready() -> void:
	var level_database = LevelManager.level_database
	if not level_database:
		printerr("Could not find level database.")
		return
		
	var levels_array = level_database.levels_array 
	if not levels_array:
		return
	
	InputManager.input_method_changed.connect(_on_input_method_changed)
	
	populate_level_buttons()
	set_pointers()
	set_inputs()
	setup_pointer_icon()
	set_input_icons(InputManager.current_input)
	show_default_category()
	select_level.call_deferred(0)

func populate_level_buttons() -> void:
	var level_database = LevelManager.level_database
	
	for category in LevelData.Category.values():
		var container = category_containers[category]
		var grid: GridContainer = container.get_node(
			"PanelContainer/GridContainer"
		)
		var levels = level_database.get_levels_category(category)
		var buttons: Array = []
		
		for level in levels:
			var global_index = level_database.levels_array.find(level) + 1
			var level_button = LEVEL_BUTTON.instantiate()
			level_button.set_button(level.level_name, global_index, level.scene)
			level_button.mouse_entered.connect(
				position_level_pointer.bind(level_button)
			)
			grid.add_child(level_button)
			buttons.append(level_button)
		
		levels_by_category[category] = buttons

func set_pointers() -> void:
	for category in category_containers:
		level_pointer_icon.top_level = true
		level_pointer_icon.visible = false
		level_pointer_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		category_pointers[category] = level_pointer_icon

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
	
	var category = LevelData.Category.values()[current_category_index]
	var container = category_containers[category]
	var grid: GridContainer = container.get_node("PanelContainer/GridContainer")
	var columns = grid.columns
	
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
		button.icon = pointer_texture
		var font: Font = button.get_theme_font("font")
		var font_size: int = button.get_theme_font_size("font_size")
		var text_height = font.get_height(font_size)
		var icon_width = int(button.size.y)
		button.add_theme_constant_override("icon_max_width", text_height)
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
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
	if is_visible:
		var focus_color = button.get_theme_color("font_focus_color")
		button.add_theme_color_override("font_color", focus_color)
	else:
		var default_color = button.get_theme_color("font_disabled")
		button.add_theme_color_override("font_color", default_color)

func show_default_category() -> void:
	current_category_index = 0
	var category = LevelData.Category.values()[0]

	set_icon_visible(category_buttons[current_category_index], true)
	category_buttons[current_category_index].grab_focus()

	for child in category_containers.values():
		child.visible = false
	category_containers[category].visible = true

	level_buttons = levels_by_category[category]
	current_level_index = 0

func switch_category(direction: int) -> void:
	if category_buttons.is_empty():
		return
	
	if is_switching_categories:
		return

	var new_index = current_category_index + direction
	var previous_index = current_category_index
	
	if new_index < 0 or new_index >= category_buttons.size():
		return
	
	is_switching_categories = true
	
	set_icon_visible(category_buttons[current_category_index], false)
	current_category_index = new_index
	set_icon_visible(category_buttons[current_category_index], true)
	category_buttons[current_category_index].grab_focus()
	
	var category = LevelData.Category.values()[current_category_index]
	var previous_category = LevelData.Category.values()[previous_index]
	
	var current_container = category_containers[category]
	var previous_container = category_containers[previous_category]

	slide_category(previous_container, current_container, direction)

	level_buttons = levels_by_category[category]
	current_level_index = 0

func slide_category(
	previous_category: MarginContainer, 
	current_category: MarginContainer,
	direction: int
) -> void:
	level_pointer_icon.visible = false
	
	var offset_x := 790
	previous_category.offset_transform_enabled = true
	
	var previous_category_tween = create_tween()
	previous_category_tween.tween_property(
		previous_category, "offset_transform_position:x", 
		offset_x * -direction, 0.5
	)
	
	previous_category_tween.finished.connect(
		_on_category_finished.bind(previous_category)
	)
	
	current_category.offset_transform_enabled = true
	current_category.offset_transform_position.x = offset_x * direction
	current_category.visible = true
	
	var current_category_tween = create_tween()
	current_category_tween.tween_property(
		current_category, "offset_transform_position:x", 
		0, 0.5
	)

func _on_category_finished(category: MarginContainer) -> void:
	category.visible = false
	if level_buttons.size() > 0:
		# Wait a frame to allow the buttons to load in first
		select_level(0)
	is_switching_categories = false

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
	var category = LevelData.Category.values()[current_category_index]
	level_pointer_icon.visible = true
	var target_x = (
		button.global_position.x - level_pointer_icon.size.x + POINTER_OVERLAP
	)
	level_pointer_icon.global_position = Vector2(
		target_x, button.global_position.y + 
		(button.size.y - level_pointer_icon.size.y) / 2.0 - VERTICAL_OFFSET
	)
