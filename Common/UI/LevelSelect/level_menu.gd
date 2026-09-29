extends MarginContainer

const LEVEL_BUTTON = preload("res://Common/UI/LevelSelect/level_button.tscn")
const POINTER_OVERLAP := 6
const VERTICAL_OFFSET := 8

@onready var container_level_select: MarginContainer = $VBoxContainer/container_level_select
@onready var grid_container: GridContainer = $VBoxContainer/container_level_select/PanelContainer/GridContainer
@onready var pointer_icon: TextureRect = $VBoxContainer/container_level_select/PanelContainer/PointerIcon

func _ready() -> void:
	var level_database = LevelManager.level_database
	if not level_database:
		printerr("Could not find level database.")
		return
		
	var levels_array = level_database.levels_array
	if not levels_array:
		return
	
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
		level_button.focus_entered.connect(
			_on_button_focused.bind(level_button)
		)
		level_button.mouse_entered.connect(
			_on_button_focused.bind(level_button)
		)
		grid_container.add_child(level_button)
	
	await get_tree().process_frame
	var default_button = grid_container.get_child(0)
	if default_button is Button:
		default_button.grab_focus()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Common/UI/main_menu.tscn")

func _on_button_focused(button: Button) -> void:
	pointer_icon.visible = true
	var target_x = button.global_position.x - pointer_icon.size.x + POINTER_OVERLAP
	pointer_icon.global_position = Vector2(target_x, button.global_position.y + (button.size.y - pointer_icon.size.y) / 2.0 - VERTICAL_OFFSET)
