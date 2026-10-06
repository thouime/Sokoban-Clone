class_name LevelData
extends Resource


enum Category { 
	BEGINNERS_TEST, WARMING_UP, 
	TRICKY, CHALLENGING, 
	ELEGANT, DIFFICULT 
}

@export var scene: PackedScene
@export var category: Category
@export var level_name: String
@export var least_moves: int = -1
@export var best_moves: int = -1

var completed: bool = false
