class_name LevelDatabase
extends Resource

enum Category { 
	BEGINNERS_TEST, WARMING_UP, 
	TRICKY, CHALLENGING, 
	ELEGANT, DIFFICULT 
}

@export var beginner_test_levels: Array[LevelData] = []
@export var warming_up_levels: Array[LevelData] = []
@export var tricky_levels: Array[LevelData] = []
@export var challenging_levels: Array[LevelData] = []
@export var elegant_levels: Array[LevelData] = []
@export var difficult_levels: Array[LevelData] = []

func get_levels_category(category: Category) -> Array[LevelData]:
	match category:
		Category.BEGINNERS_TEST: return beginner_test_levels
		Category.WARMING_UP: return warming_up_levels
		Category.TRICKY: return tricky_levels
		Category.CHALLENGING: return challenging_levels
		Category.ELEGANT: return elegant_levels
		Category.DIFFICULT: return difficult_levels
	return []

func get_level(category_array: Array, level: int) -> PackedScene:
	if level <= category_array.size():
		return category_array[level - 1].scene
	print("Level not found!")
	return null

func get_data(category: Category, level: int) -> LevelData:
	var category_array = get_levels_category(category)
	if level <= category_array.size():
		return category_array[level - 1]
	print("Level not found!")
	return null
