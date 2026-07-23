class_name Main
extends Node2D

const WATER_STREAM_TEXTURES: Dictionary[Vector2i, Texture2D] = {
	Vector2i.ZERO: preload("res://assets/water_streams/center.png"),
	Vector2i.UP: preload("res://assets/water_streams/up.png"),
	Vector2i.DOWN: preload("res://assets/water_streams/down.png"),
	Vector2i.LEFT: preload("res://assets/water_streams/left.png"),
	Vector2i.RIGHT: preload("res://assets/water_streams/right.png")
}

const WATER_BALLOON_TEXTURE: Texture2D = preload("res://assets/water_balloons/water_melon.png")
const GAME_ITEM_WATER_BALLOON_TEXTURE: Texture2D = preload("res://assets/game_items/water_balloon.png")

const ZOMKKAN_VIEW := preload("res://scenes/zomkkan_view.tscn")
const BAZZI_VIEW := preload("res://scenes/bazzi_view.tscn")
var view_by_character: Dictionary[Character, CharacterView] = {}

var map := Map.new()
var battle := Battle.new(map)
var player: Character
@onready var character_views: Node2D = $CharacterViews
@onready var water_balloon_views: Node2D = $WaterBalloonViews
@onready var water_stream_views: Node2D = $WaterStreamViews
@onready var game_item_views: Node2D = $GameItemViews
@onready var win_label: Label = $CanvasLayer/WinLabel
@onready var lose_label: Label = $CanvasLayer/LoseLabel
@onready var draw_label: Label = $CanvasLayer/DrawLabel

func _ready() -> void:
	var npc := Npc.new(Vector2i(1, 4))
	var character := Character.new(Vector2i(10, 6))
	map.add_character(npc)
	map.add_character(character)
	_render_characters()
	player = character
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
	# 사라진 캐릭터의 뷰 정리
	for character in view_by_character.keys():
		if character not in map.characters():
			var view: CharacterView = view_by_character[character]
			view_by_character.erase(character)
			character_views.remove_child(view)
			view.queue_free()
	# 새 캐릭터 뷰 생성
	for character in map.characters():
		if character not in view_by_character:
			var view: CharacterView
			if character is Npc:
				view = ZOMKKAN_VIEW.instantiate()
			else:
				view = BAZZI_VIEW.instantiate()
			view_by_character[character] = view
			character_views.add_child(view)
	# sync하여 position 갱신
	for character in map.characters():
		view_by_character[character].sync(character)

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

	for water_stream in map.water_streams():
		var view := Sprite2D.new()
		view.texture = WATER_STREAM_TEXTURES[water_stream.direction]
		view.scale = Vector2.ONE * (Map.PIXELS_PER_CELL / 42.0)
		view.position = Map.to_pixel(water_stream.position)
		view.centered = false
		water_stream_views.add_child(view)

func _render_game_items() -> void:
	for view in game_item_views.get_children():
		game_item_views.remove_child(view)
		view.queue_free()

	for game_item in map.game_items():
		var view := Sprite2D.new()
		match game_item.type:
			GameItem.INCREASE_WATER_BALLOON_COUNT:
				view.texture = GAME_ITEM_WATER_BALLOON_TEXTURE
				view.scale = Vector2.ONE * (Map.PIXELS_PER_CELL / 100.0)
				view.position = Map.to_pixel(game_item.position) + Vector2(Map.PIXELS_PER_CELL / 2.0, Map.PIXELS_PER_CELL)
				view.offset = Vector2(-50, -106) # (-w/2, -h)
		view.centered = false
		game_item_views.add_child(view)

func _render_game_over_label() -> void:
	win_label.visible = battle.is_win()
	lose_label.visible = battle.is_lose()
	draw_label.visible = battle.is_draw()

func handle_key(key: Key) -> void:
	match key:
		KEY_SPACE:
			player.place_water_balloon(map)
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
	for character in map.characters():
		if character is Npc:
			character.move(character.decide_move_direction(map), delta, map.water_balloon_positions())
			if character.should_place_water_balloon(map):
				character.place_water_balloon(map)
		else:
			var direction := _read_move_direction()
			character.move(direction, delta, map.water_balloon_positions())

	map.tick(delta)
	_render_water_balloons()
	_render_water_streams()
	_render_characters()
	_render_game_items()
	_render_game_over_label()
