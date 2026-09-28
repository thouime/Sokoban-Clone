extends MarginContainer

const LEVEL_BUTTON = preload("res://Common/UI/LevelSelect/level_button.tscn")

@onready var container_level_select: MarginContainer = $VBoxContainer/container_level_select
@onready var grid_container: GridContainer = $VBoxContainer/container_level_select/PanelContainer/GridContainer

func _ready() -> void:
	var level_database = LevelManager.level_database
	if not level_database:
		printerr("Could not find level database.")
		return
	var levels_array = level_database.levels_array
	if not levels_array:
		return
	for i in range(levels_array.size()):
		var level = levels_array[i]
		var level_button = LEVEL_BUTTON.instantiate()
		level_button.set_button(
			level.level_name, 
			i+1,
			level.scene
			)
		grid_container.add_child(level_button)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Common/UI/main_menu.tscn")
