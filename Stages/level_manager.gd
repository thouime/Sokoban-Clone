extends Node

const PLAYER = preload("res://Entities/Player/player.tscn")
const BOX = preload("res://Entities/Objects/box.tscn")
const SWITCH = preload("res://Entities/Objects/switch.tscn")

var level_database: LevelDatabase
var level_instance: Node
var current_level := 2

var moveables: Array
var past_turns: Array[Array]

var level_container: Node

func _ready() -> void:
	if get_tree().current_scene.name != "Main":
		return
	level_container = get_tree().root.get_node("Main/LevelContainer")
	level_database = load("res://Stages/level_database.tres")
	load_level()
	
func level_changed() -> void:
	# set tilemap
	past_turns.clear()

func load_level() -> void:
	var level_scene: PackedScene = level_database.get_level(current_level)
	if not level_scene:
		printerr("Level not found!")
		return
	
	if level_instance:
		level_instance.queue_free()
	
	level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)
	center_level(level_instance, get_viewport().get_visible_rect().size, 64)
	
	# Populate the map with player, boxes, and switches
	spawn_entities()
	
func spawn_entities() -> void:
	for tile_map_layer in level_instance.get_children():
		if not tile_map_layer is TileMapLayer:
			continue
		if tile_map_layer.name == "Objects":
			set_level(tile_map_layer)

func set_level(layer: TileMapLayer) -> void:
	for tile in layer.get_used_cells():
		var tile_data = layer.get_cell_tile_data(tile)
		if not tile_data:
			continue
		
		var object_type = tile_data.get_custom_data("object_type")
		if object_type.is_empty():
			continue
		
		var world_position = layer.map_to_local(tile)
		spawn_object(object_type, world_position, layer)
		layer.erase_cell(tile)

func spawn_object(
	object_type: String, world_position: Vector2, layer: TileMapLayer
	) -> void:
	match object_type:
		"player":
			var player = PLAYER.instantiate()
			player.position = world_position
			level_instance.add_child(player)
		"box":
			var box = BOX.instantiate()
			box.position = world_position
			box.tile = layer.local_to_map(world_position)
			level_instance.add_child(box)
			box.add_to_group("boxes")
		"switch":
			var switch = SWITCH.instantiate()
			switch.position = world_position
			switch.tile_position = layer.local_to_map(world_position)
			level_instance.add_child(switch)
			switch.activated.connect(_on_switch_changed)
			switch.deactivated.connect(_on_switch_changed)
			switch.add_to_group("switches")

func center_level(level: Node, viewport_size: Vector2, tile_size: int) -> void:
	var floor_layer: TileMapLayer = level.get_node("Floor")
	var used_rect = floor_layer.get_used_rect()

	var level_pixel_size = Vector2(used_rect.size) * tile_size
	var level_pixel_start = Vector2(used_rect.position) * tile_size

	var offset = (viewport_size - level_pixel_size) / 2.0 - level_pixel_start
	offset = floor(offset / 64) * 64

	level.position = offset

func get_moveable_at_tile(tile: Vector2i) -> Moveable:
	for node: Moveable in moveables:
		if node.tile == Vector2(tile):
			return node
	return null

func add_move_to_turn(node: Moveable, direction: Vector2i) -> void:
	var move := Move.new()
	move.node = node
	move.direction = direction
	past_turns.back().append(move)

func undo_last_move() -> void:
	if !past_turns.is_empty():
		var last_moves: Array = past_turns.pop_back()
		for move: Move in last_moves:
			var node = move.node
			if node.has_method("reverse_animation"):
				node.reverse_animation(move.direction)
			node.set_movement(-move.direction)
			node.set_target(node.get_tile_position(), node.direction)

func _on_switch_changed() -> void:
	check_win_condition.call_deferred()

func check_win_condition() -> void:
	var switches = get_tree().get_nodes_in_group("switches")
	var boxes = get_tree().get_nodes_in_group("boxes")
	var activated_count = 0
	for switch in switches:
		for box in boxes:
			if Vector2i(box.tile) == switch.tile_position:
				activated_count +=1
				break
	
	if activated_count == switches.size():
		print("Level Completed!")
		
class Move:
	var node: Moveable
	var direction: Vector2i
