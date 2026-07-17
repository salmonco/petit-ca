class_name Main
extends Node2D

const CHARACTER_COLOR := Color.LIME_GREEN
const WATER_BALLOON_COLOR := Color.SKY_BLUE
const WATER_STREAM_COLOR := Color.AQUA
const BUBBLE_COLOR := Color.ORANGE

var map := Map.new()
@onready var character_views: Node2D = $CharacterViews
@onready var water_balloon_views: Node2D = $WaterBalloonViews
@onready var water_stream_views: Node2D = $WaterStreamViews
@onready var game_over_label: Label = $CanvasLayer/GameOverLabel

func _ready() -> void:
	var character := Character.new(Vector2i(10, 6))
	map.add_character(character)
	_render_characters()

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
		var view := ColorRect.new()
		view.size = Vector2.ONE * Map.PIXELS_PER_CELL
		if character.is_trapped:
			view.color = BUBBLE_COLOR
		else:
			view.color = CHARACTER_COLOR
		view.position = Map.to_pixel(character.position)
		character_views.add_child(view)

func _render_water_balloons() -> void:
	for view in water_balloon_views.get_children():
		water_balloon_views.remove_child(view)
		view.queue_free()

	for cell in map.water_balloon_positions():
		var view := ColorRect.new()
		view.size = Vector2.ONE * Map.PIXELS_PER_CELL
		view.color = WATER_BALLOON_COLOR
		view.position = Map.to_pixel(cell)
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

func _render_game_over_label() -> void:
	if map.is_game_over():
		game_over_label.visible = true
	else:
		game_over_label.visible = false

func handle_key(key: Key) -> void:
	match key:
		KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT:
			var direction := Direction.from_key(key)
			for character in map.characters():
				character.move(direction)
			_render_characters()
		KEY_SPACE:
			for character in map.characters():
				character.place_water_balloon(map)
			_render_water_balloons()

func tick(delta: float) -> void:
	map.tick(delta)
	_render_water_balloons()
	_render_water_streams()
	_render_characters()
	_render_game_over_label()