extends Button

var level_scene: PackedScene
var level_num: int
var level_name: String

func set_button(name, num, level) -> void:
	level_name = name
	level_num = num
	var display_text = "%02d" % level_num
	self.text = str(display_text)
	level_scene = level
