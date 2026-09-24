extends Moveable

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycasts := {
	Vector2.UP: $RayCastUp,
	Vector2.DOWN: $RayCastDown,
	Vector2.RIGHT: $RayCastRight,
	Vector2.LEFT: $RayCastLeft
}

func _ready() -> void:
	can_push = true

func _physics_process(delta: float) -> void:
	super(delta)
	if not is_moving:
		animated_sprite_2d.stop()
	get_input()

func get_input() -> void:
	var input_direction = movement_direction()
	if !input_direction:
		return
	if can_move(input_direction, raycasts[input_direction]):
		LevelManager.past_turns.append([])
		update_animation(input_direction)
		move(input_direction)

func movement_direction() -> Vector2:
	if Input.is_action_pressed("up"):
		return Vector2(0, -1)
	elif Input.is_action_pressed("down"):
		return Vector2(0, 1)
	elif Input.is_action_pressed("right"):
		return Vector2(1, 0)
	elif Input.is_action_pressed("left"):
		return Vector2(-1, 0)
	elif Input.is_action_pressed("Z"):
		if not is_moving:
			LevelManager.undo_last_move()
	return Vector2.ZERO

func update_animation(input_direction):
	if abs(input_direction.x) > abs(input_direction.y):
		animated_sprite_2d.play("right" if input_direction.x > 0 else "left")
	else:
		animated_sprite_2d.play("down" if input_direction.y > 0 else "up")

func reverse_animation(input_direction):
	if abs(input_direction.x) > abs(input_direction.y):
		animated_sprite_2d.play_backwards(
			"right" if input_direction.x > 0 else "left"
		)
	else:
		animated_sprite_2d.play_backwards(
			"down" if input_direction.y > 0 else "up"
		)
