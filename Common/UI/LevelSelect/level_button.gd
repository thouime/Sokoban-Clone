extends Button

var level_scene: PackedScene
var level_num: int
var level_name: String

func set_button(lvl_name, num, level) -> void:
	level_name = lvl_name
	level_num = num
	var display_text = "%02d" % level_num
	self.text = str(display_text)
	level_scene = level

func _on_pressed() -> void:
	LevelManager.current_level = level_num
	get_tree().change_scene_to_file("res://Stages/main.tscn")
