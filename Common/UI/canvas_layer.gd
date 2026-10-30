class_name InterfaceEffect
extends CanvasLayer

@export var transition_time: float = 0.5

@onready var mosaic: ColorRect = $Mosaic
@onready var vertical_squash: ColorRect = $VerticalSquash

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
	mosaic.material.set_shader_parameter("block_size", value)

func set_fade(value: float) -> void:
	mosaic.material.set_shader_parameter("fade", value)

func set_progress(value: float) -> void:
	vertical_squash.material.set_shader_parameter("progress", value)
	
func shrink_in() -> void:
	var tween = create_tween()
	tween.tween_method(set_progress, 1.0, 0.0, 0.5)
	await tween.finished

func expand_out() -> void:
	var tween = create_tween()
	tween.tween_method(set_progress, 0.0, 1.0, 0.5)
	await tween.finished
	
func use_mosaic(enabled: bool) -> void:
	mosaic.visible = enabled
	vertical_squash.visible = not enabled
	
