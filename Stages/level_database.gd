class_name LevelDatabase
extends Resource
@export var levels_array: Array[LevelData] = []

func get_level(level: int) -> PackedScene:
	if level <= levels_array.size():
		return levels_array[level - 1].scene
	else:
		print("Level not found!")
		return null
