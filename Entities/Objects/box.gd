extends Moveable

@onready var raycasts := {
	Vector2.UP: $CharacterBody2D/RayCastUp,
	Vector2.DOWN: $CharacterBody2D/RayCastDown,
	Vector2.RIGHT: $CharacterBody2D/RayCastRight,
	Vector2.LEFT: $CharacterBody2D/RayCastLeft
}

func _physics_process(delta: float) -> void:
	super(delta)
