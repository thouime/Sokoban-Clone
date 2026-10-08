class_name LevelDatabase
extends Resource

@export var levels_array: Array[LevelData] = []

func get_level(level: int) -> PackedScene:
	if level <= levels_array.size():
		return levels_array[level - 1].scene
	print("Level not found!")
	return null

func get_data(level: int) -> LevelData:
	if level <= levels_array.size():
		return levels_array[level - 1]
	print("Level not found!")
	return null

func get_levels_category(category: LevelData.Category) -> Array[LevelData]:
	return levels_array.filter(func(level): return level.category == category)
	
func get_categories() -> Array:
	return LevelData.Category.values()
