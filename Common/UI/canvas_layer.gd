extends CanvasLayer

@export var transition_time: float = 0.5

@onready var fade_rect: ColorRect = $Fade

func transition_out() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_method(set_block_size, 1.0, 128.0, transition_time)
	tween.tween_method(set_fade, 0.0, 1.0, transition_time)
	await tween.finished

func transition_in() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_method(set_block_size, 128.0, 1.0, transition_time)
	tween.tween_method(set_fade, 1.0, 0.0, transition_time)
	await tween.finished

func set_block_size(value: float) -> void:
	fade_rect.material.set_shader_parameter("block_size", value)

func set_fade(value: float) -> void:
	fade_rect.material.set_shader_parameter("fade", value)
