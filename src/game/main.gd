class_name Main
extends Node2D

const WATER_BALLOON_COLOR := Color.SKY_BLUE
const WATER_STREAM_COLOR := Color.AQUA

var map := Map.new()
var character := Character.new(Vector2i(10, 6))
@onready var character_view: ColorRect = $CharacterView
@onready var water_balloon_views: Node2D = $WaterBalloonViews
@onready var water_stream_views: Node2D = $WaterStreamViews

func _ready() -> void:
	character_view.size = Vector2.ONE * Map.PIXELS_PER_CELL
	_render_character()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var keycode := (event as InputEventKey).keycode
		handle_key(keycode)

func _process(delta: float) -> void:
	tick(delta)

func _render_character() -> void:
	character_view.position = Map.to_pixel(character.position)

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

func handle_key(key: Key) -> void:
	match key:
		KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT:
			var direction := Direction.from_key(key)
			character.move(direction)
			_render_character()
		KEY_SPACE:
			character.place_water_balloon(map)
			_render_water_balloons()

func tick(delta: float) -> void:
	map.tick(delta)
	_render_water_balloons()
	_render_water_streams()
