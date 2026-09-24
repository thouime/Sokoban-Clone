extends Area2D

signal activated
signal deactivated

var tile_position: Vector2i

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		activated.emit()

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		deactivated.emit()
