class_name Main
extends Node2D

const WATER_STREAM_TEXTURES: Dictionary[String, Texture2D] = {
	"center": preload("res://assets/water_streams/center.png"),
	"straight": preload("res://assets/water_streams/straight_up.png"),
	"end": preload("res://assets/water_streams/end_up.png"),
}
const WATER_BALLOON_WATER_MELON_TEXTURE: Texture2D = preload("res://assets/water_balloons/water_melon.png")
const WATER_BALLOON_NIGHTMARE_TEXTURE: Texture2D = preload("res://assets/water_balloons/nightmare.png")
const PLAYER_WATER_BALLOON_TEXTURE := WATER_BALLOON_WATER_MELON_TEXTURE
const NPC_WATER_BALLOON_TEXTURE := WATER_BALLOON_NIGHTMARE_TEXTURE
const GAME_ITEM_WATER_BALLOON_TEXTURE: Texture2D = preload("res://assets/game_items/water_balloon.png")
const GAME_ITEM_WHITE_POTION_TEXTURE: Texture2D = preload("res://assets/game_items/white_potion.png")
const GAME_ITEM_SPEED_TEXTURE: Texture2D = preload("res://assets/game_items/speed.png")

const ZOMKKAN_VIEW := preload("res://scenes/zomkkan_view.tscn")
const BAZZI_VIEW := preload("res://scenes/bazzi_view.tscn")
var view_by_character: Dictionary[Character, CharacterView] = {}

@onready var character_views: Node2D = $CharacterViews
@onready var water_balloon_views: Node2D = $WaterBalloonViews
@onready var water_stream_views: Node2D = $WaterStreamViews
@onready var game_item_views: Node2D = $GameItemViews
@onready var win_label: Label = $CanvasLayer/WinLabel
@onready var lose_label: Label = $CanvasLayer/LoseLabel
@onready var draw_label: Label = $CanvasLayer/DrawLabel

var battle: Battle
var first_character: Character
var second_character: Character

func start_battle(mode: StringName) -> void:
	var map := Map.new()
	battle = Battle.new(map, mode)
	match mode:
		BattleMode.MONSTER:
			var monster := Npc.new(Vector2i(1, 6))
			var human := Character.new(Vector2i(13, 6))
			battle.get_map().add_character(monster)
			battle.get_map().add_character(human)
		BattleMode.LOCAL_MULTI:
			var human1 := Character.new(Vector2i(1, 6))
			var human2 := Character.new(Vector2i(13, 6))
			battle.get_map().add_character(human1)
			battle.get_map().add_character(human2)
	_render_characters()
	first_character = battle.get_map().characters()[0]
	second_character = battle.get_map().characters()[1]

func handle_key_pressed(key: Key) -> void:
	match key:
		KEY_SPACE:
			if battle.get_mode() == BattleMode.MONSTER:
				second_character.place_water_balloon(battle.get_map())
				_render_water_balloons()
		KEY_UP:
			second_character.move_direction = Direction.from_key(KEY_UP)
		KEY_DOWN:
			second_character.move_direction = Direction.from_key(KEY_DOWN)
		KEY_LEFT:
			second_character.move_direction = Direction.from_key(KEY_LEFT)
		KEY_RIGHT:
			second_character.move_direction = Direction.from_key(KEY_RIGHT)

func handle_key_released(key: Key) -> void:
	match key:
		KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT:
			second_character.move_direction = Vector2i.ZERO

func tick(delta: float) -> void:
	for character in battle.get_map().characters():
		if character is Npc:
			character.move(character.decide_move_direction(battle.get_map()), delta, battle.get_map().water_balloon_positions())
			if character.should_place_water_balloon(battle.get_map()):
				character.place_water_balloon(battle.get_map())
		else:
			character.move(character.move_direction, delta, battle.get_map().water_balloon_positions())

	battle.tick(delta)
	_render_water_balloons()
	_render_water_streams()
	_render_characters()
	_render_game_items()
	_render_game_over_label()

func _ready() -> void:
	start_battle(BattleMode.MONSTER)
	# 물풍선 아이템 배치	
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(5, 4))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(1, 7))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(8, 5))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(13, 12))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(12, 6))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(15, 1))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(0, 11))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(11, 11))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(2, 2))
	# 물줄기 아이템 배치
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_STREAM_LENGTH, Vector2i(11, 6))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_STREAM_LENGTH, Vector2i(1, 3))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_STREAM_LENGTH, Vector2i(15, 13))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_STREAM_LENGTH, Vector2i(10, 9))
	battle.get_map().add_game_item(GameItem.INCREASE_WATER_STREAM_LENGTH, Vector2i(10, 0))
	# 스피드 아이템 배치
	battle.get_map().add_game_item(GameItem.INCREASE_SPEED, Vector2i(9, 9))
	battle.get_map().add_game_item(GameItem.INCREASE_SPEED, Vector2i(5, 9))
	battle.get_map().add_game_item(GameItem.INCREASE_SPEED, Vector2i(8, 10))
	battle.get_map().add_game_item(GameItem.INCREASE_SPEED, Vector2i(14, 1))
	battle.get_map().add_game_item(GameItem.INCREASE_SPEED, Vector2i(0, 1))
	_render_game_items()
	_render_game_over_label()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_echo():
		var keycode := (event as InputEventKey).keycode
		if event.is_pressed():
			handle_key_pressed(keycode)
		else:
			handle_key_released(keycode)

func _process(delta: float) -> void:
	tick(delta)

func _render_characters() -> void:
	# 사라진 캐릭터의 뷰 정리
	for character in view_by_character.keys():
		if character not in battle.get_map().characters():
			var view: CharacterView = view_by_character[character]
			view_by_character.erase(character)
			character_views.remove_child(view)
			view.queue_free()
	# 새 캐릭터 뷰 생성
	for character in battle.get_map().characters():
		if character not in view_by_character:
			var view: CharacterView
			if character is Npc:
				view = ZOMKKAN_VIEW.instantiate()
			else:
				view = BAZZI_VIEW.instantiate()
			view_by_character[character] = view
			character_views.add_child(view)
	# sync하여 position 갱신
	for character in battle.get_map().characters():
		view_by_character[character].sync(character)

func _render_water_balloons() -> void:
	for view in water_balloon_views.get_children():
		water_balloon_views.remove_child(view)
		view.queue_free()

	for water_balloon in battle.get_map().water_balloons():
		var view := Sprite2D.new()
		if water_balloon.placed_by is Npc:
			view.texture = NPC_WATER_BALLOON_TEXTURE
		else:
			view.texture = PLAYER_WATER_BALLOON_TEXTURE
		view.scale = Vector2.ONE * (Map.PIXELS_PER_CELL / 42.0)
		view.position = Map.to_pixel(water_balloon.position)
		view.centered = false
		water_balloon_views.add_child(view)

func _render_water_streams() -> void:
	for view in water_stream_views.get_children():
		water_stream_views.remove_child(view)
		view.queue_free()

	for water_stream in battle.get_map().water_streams():
		var view := Sprite2D.new()
		view.texture = WATER_STREAM_TEXTURES[water_stream.position_type]
		match water_stream.direction:
			Vector2i.DOWN:
				view.flip_v = true
			Vector2i.LEFT:
				view.rotation_degrees = -90
			Vector2i.RIGHT:
				view.rotation_degrees = 90
		view.scale = Vector2.ONE * (Map.PIXELS_PER_CELL / 42.0)
		view.position = Map.to_pixel(water_stream.position) + Vector2.ONE * (Map.PIXELS_PER_CELL / 2.0)
		water_stream_views.add_child(view)

func _render_game_items() -> void:
	for view in game_item_views.get_children():
		game_item_views.remove_child(view)
		view.queue_free()

	for game_item in battle.get_map().game_items():
		var view := Sprite2D.new()
		match game_item.type:
			GameItem.INCREASE_WATER_BALLOON_COUNT:
				view.texture = GAME_ITEM_WATER_BALLOON_TEXTURE
			GameItem.INCREASE_WATER_STREAM_LENGTH:
				view.texture = GAME_ITEM_WHITE_POTION_TEXTURE
			GameItem.INCREASE_SPEED:
				view.texture = GAME_ITEM_SPEED_TEXTURE
		view.scale = Vector2.ONE * (Map.PIXELS_PER_CELL / 64.0)
		view.position = Map.to_pixel(game_item.position) + Vector2(Map.PIXELS_PER_CELL / 2.0, Map.PIXELS_PER_CELL)
		view.offset = Vector2(-32, -96) # (-w/2, -h)
		view.centered = false
		game_item_views.add_child(view)

func _render_game_over_label() -> void:
	win_label.visible = battle.is_game_over() and battle.result_type == "win"
	lose_label.visible = battle.is_game_over() and battle.result_type == "lose"
	draw_label.visible = battle.is_game_over() and battle.result_type == "draw"
