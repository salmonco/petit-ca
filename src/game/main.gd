class_name Main
extends Node2D

const WATER_STREAM_COLOR := Color.AQUA
const WATER_BALLOON_TEXTURE: Texture2D = preload("res://assets/water_balloons/water_melon.png")
const CHARACTER_TEXTURE: Texture2D = preload("res://assets/characters/bazzi.png")
const BUBBLE_TEXTURE: Texture2D = preload("res://assets/characters/bazzi_bubble.png")
const WHITE_POTION_TEXTURE: Texture2D = preload("res://assets/game_items/white_potion.png")

var map := Map.new()
@onready var character_views: Node2D = $CharacterViews
@onready var water_balloon_views: Node2D = $WaterBalloonViews
@onready var water_stream_views: Node2D = $WaterStreamViews
@onready var game_item_views: Node2D = $GameItemViews
@onready var game_over_label: Label = $CanvasLayer/GameOverLabel

func _ready() -> void:
	var character := Character.new(Vector2i(10, 6))
	map.add_character(character)
	_render_characters()
	map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(5, 4))
	map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(1, 7))
	map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(8, 5))
	map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(13, 12))
	map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(12, 6))
	_render_game_items()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var keycode := (event as InputEventKey).keycode
		handle_key(keycode)

func _process(delta: float) -> void:
	tick(delta)

func _render_characters() -> void:
	for view in character_views.get_children():
		character_views.remove_child(view)
		view.queue_free()
	
	for character in map.characters():
		var view := Sprite2D.new()
		if character.is_trapped():
			view.texture = BUBBLE_TEXTURE
			view.scale = Vector2.ONE * (Map.PIXELS_PER_CELL / 135.0)
			view.position = character.pixel_position()
		else:
			view.texture = CHARACTER_TEXTURE
			view.scale = Vector2.ONE * (Map.PIXELS_PER_CELL / 220.0)
			view.position = character.pixel_position() + Vector2(Map.PIXELS_PER_CELL / 2.0, Map.PIXELS_PER_CELL)
			view.offset = Vector2(-110, -280) # (-w/2, -h)
		view.centered = false
		character_views.add_child(view)

func _render_water_balloons() -> void:
	for view in water_balloon_views.get_children():
		water_balloon_views.remove_child(view)
		view.queue_free()

	for cell in map.water_balloon_positions():
		var view := Sprite2D.new()
		view.texture = WATER_BALLOON_TEXTURE
		view.scale = Vector2.ONE * (Map.PIXELS_PER_CELL / 42.0)
		view.position = Map.to_pixel(cell)
		view.centered = false
		water_balloon_views.add_child(view)

func _render_water_streams() -> void:
	for view in water_stream_views.get_children():
		water_stream_views.remove_child(view)
		view.queue_free()

	for cell in map.water_stream_positions():
		var view := ColorRect.new()
		view.size = Vector2.ONE * Map.PIXELS_PER_CELL
		view.color = WATER_STREAM_COLOR
		view.position = Map.to_pixel(cell)
		water_stream_views.add_child(view)

func _render_game_items() -> void:
	for view in game_item_views.get_children():
		game_item_views.remove_child(view)
		view.queue_free()

	for game_item in map.game_items():
		var view := Sprite2D.new()
		match game_item.type:
			GameItem.INCREASE_WATER_BALLOON_COUNT:
				view.texture = WHITE_POTION_TEXTURE
				view.scale = Vector2.ONE * (Map.PIXELS_PER_CELL / 152.0)
				view.position = Map.to_pixel(game_item.position) + Vector2(Map.PIXELS_PER_CELL / 2.0, Map.PIXELS_PER_CELL)
				view.offset = Vector2(-76, -176) # (-w/2, -h)
		view.centered = false
		game_item_views.add_child(view)

func _render_game_over_label() -> void:
	if map.is_game_over():
		game_over_label.visible = true
	else:
		game_over_label.visible = false

func handle_key(key: Key) -> void:
	match key:
		KEY_SPACE:
			for character in map.characters():
				character.place_water_balloon(map)
			_render_water_balloons()

func _read_move_direction() -> Vector2i:
	if Input.is_key_pressed(KEY_UP):
		return Direction.from_key(KEY_UP)
	if Input.is_key_pressed(KEY_DOWN):
		return Direction.from_key(KEY_DOWN)
	if Input.is_key_pressed(KEY_LEFT):
		return Direction.from_key(KEY_LEFT)
	if Input.is_key_pressed(KEY_RIGHT):
		return Direction.from_key(KEY_RIGHT)
	return Vector2i.ZERO

func tick(delta: float) -> void:
	var direction := _read_move_direction()
	for character in map.characters():
		character.move(direction, delta, map.water_balloon_positions())

	map.tick(delta)
	_render_water_balloons()
	_render_water_streams()
	_render_characters()
	_render_game_items()
	_render_game_over_label()