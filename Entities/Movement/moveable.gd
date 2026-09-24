class_name Moveable
extends Node2D
## Movement code for anything that can be moved
##
## To be inherited by moveable entities

var speed := 200

var tile := Vector2.ZERO
var tile_size := 64
var center_offset := Vector2(tile_size / 2.0, tile_size / 2.0)

var can_push: bool = false
var is_moving: bool
var target_position := Vector2.ZERO
var direction: Vector2

var pending_box: PendingBox = null

func _ready() -> void:
	is_moving = false

func _enter_tree() -> void:
	LevelManager.moveables.append(self)

func _exit_tree() -> void:
	LevelManager.moveables.erase(self)

func _physics_process(delta: float) -> void:
	if not is_moving:
		return
		
	slide(delta)

func set_target(tile_pos: Vector2, dir: Vector2) -> void:
	target_position = ((tile_pos + dir) * tile_size) + center_offset

func get_tile_position() -> Vector2:
	return floor(global_position / tile_size)

func can_move(dir: Vector2, ray: RayCast2D) -> bool:
	if is_moving:
		return false
	
	if ray.is_colliding():
		return check_collisions(dir, ray, get_tile_position())

	# Move player if they aren't moving
	if not is_moving:
		# Center of the tile
		set_target(get_tile_position(), dir)
		return true

	return not is_moving

func check_collisions(
	dir: Vector2, 
	ray: RayCast2D, 
	tile_position: Vector2
	) -> bool:
	
	var collider = ray.get_collider()
	if collider is TileMapLayer:
		return false
	elif collider is CharacterBody2D:
		if not can_push:
			return false
		var box = collider.get_parent()
		if box.can_move(dir, box.raycasts[dir]):
			pending_box = PendingBox.new()
			pending_box.collider = collider
			pending_box.target = tile_position
			return true
	return false

func move_box(
	dir: Vector2, 
	collider: CharacterBody2D, 
	target_tile: Vector2
	) -> void:

	var box = collider.get_parent()
	
	set_target(target_tile, dir)
	box.move(dir)
		

func set_movement(dir: Vector2) -> void:
	is_moving = true
	direction = dir
	tile += dir
	
	if pending_box:
		move_box(dir, pending_box.collider, pending_box.target)

func move(dir: Vector2) -> void:
	set_movement(dir)
	LevelManager.add_move_to_turn(self, direction)

func slide(delta: float):
	var distance = target_position - global_position
	if distance.length() <= speed * delta:
		global_position = target_position
		is_moving = false
		pending_box = null
	else:
		global_position += direction * speed * delta
		
class PendingBox:
	var collider: CharacterBody2D
	var target: Vector2
