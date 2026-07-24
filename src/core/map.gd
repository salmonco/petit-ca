class_name Map
extends RefCounted

const GRID_SIZE := Vector2i(15, 13)
const PIXELS_PER_CELL := 64
const TRAP_MARGIN := 0.35

var _characters: Array[Character] = []
var _water_balloons: Dictionary[Vector2i, WaterBalloon] = {}
var _water_streams: Array[WaterStream] = []
var _game_items: Array[GameItem] = []

static func to_pixel(cell: Vector2i) -> Vector2:
	return Vector2(cell) * PIXELS_PER_CELL

static func to_pixel_center(cell: Vector2i) -> Vector2:
	return to_pixel(cell) + Vector2.ONE * (Map.PIXELS_PER_CELL / 2.0)

func add_water_balloon(water_balloon: WaterBalloon) -> bool:
	if has_water_balloon(water_balloon.position):
		return false
	_water_balloons.set(water_balloon.position, water_balloon)
	return true

func _remove_water_balloon(position: Vector2i) -> void:
	_water_balloons.erase(position)

func has_water_balloon(position: Vector2i) -> bool:
	return _water_balloons.has(position)

func water_balloon_count() -> int:
	return _water_balloons.size()

func water_balloon_positions() -> Array[Vector2i]:
	return _water_balloons.keys()

func tick(delta: float) -> void:
	# 물줄기 tick
	var expired_water_streams: Array[WaterStream] = []
	for water_stream: WaterStream in _water_streams:
		if water_stream.tick(delta):
			expired_water_streams.append(water_stream)
		else:
			check_trap_character_in_bubble(water_stream.position)
	for water_stream: WaterStream in expired_water_streams:
		_remove_water_stream(water_stream)
	
	# 물풍선 tick
	for water_balloon: WaterBalloon in _water_balloons.values():
		if water_balloon.tick(delta):
			_remove_water_balloon(water_balloon.position)
			add_water_streams(water_balloon.position, water_balloon.stream_length)
			check_trap_character_in_bubble(water_balloon.position)

	# 물방울 tick
	for character in _characters.duplicate():
		if character.is_trapped():
			if character.bubble.tick(delta):
				# 자동 아웃
				let_character_out(character)
	
	# 물줄기 연쇄
	while true:
		var popped_water_balloons := check_pop_water_balloons()
		if popped_water_balloons.is_empty():
			break
		for water_balloon: WaterBalloon in popped_water_balloons:
			add_water_streams(water_balloon.position, water_balloon.stream_length)
			check_trap_character_in_bubble(water_balloon.position)
	
	# 상대방 킬
	var trapped_humans: Array[Character] = []
	var alive_humans: Array[Character] = []
	var trapped_npcs: Array[Npc] = []
	var alive_npcs: Array[Npc] = []
	for character in _characters:
		if character is Npc:
			if character.is_trapped():
				trapped_npcs.append(character)
			else:
				alive_npcs.append(character)
		else:
			if character.is_trapped():
				trapped_humans.append(character)
			else:
				alive_humans.append(character)
	for trapped_human in trapped_humans:
		for alive_npc in alive_npcs:
			if trapped_human.position() == alive_npc.position():
				let_character_out(trapped_human)
	for trapped_npc in trapped_npcs:
		for alive_human in alive_humans:
			if trapped_npc.position() == alive_human.position():
				let_character_out(trapped_npc)

	# 게임 아이템 먹음
	for character in _characters:
		if character.is_trapped():
			continue
		for game_item in _game_items.duplicate():
			if character.position() == game_item.position:
				character.get_game_item(game_item.type)
				_remove_game_item(game_item)
	
	# 물줄기를 맞은 게임 아이템 제거
	for game_item in _game_items.duplicate():
		if water_stream_positions().has(game_item.position):
			_remove_game_item(game_item)

func add_water_streams(center_cell: Vector2i, length: int) -> void:
	var center_water_stream := WaterStream.new(center_cell, Vector2i.ZERO, "center")
	add_water_stream(center_water_stream)
	for depth in range(1, length + 1):
		for direction in WaterStream.DIRECTION:
			var cell := center_cell + direction * depth
			var position_type: String
			if depth == length:
				position_type = "end"
			else:
				position_type = "straight"
			var water_stream := WaterStream.new(cell, direction, position_type)
			add_water_stream(water_stream)

func add_water_stream(water_stream: WaterStream) -> void:
	_water_streams.append(water_stream)

func _remove_water_stream(water_stream: WaterStream) -> void:
	_water_streams.erase(water_stream)

func has_water_stream(position: Vector2i) -> bool:
	return water_stream_positions().has(position)

func water_stream_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for water_stream in _water_streams:
		positions.append(water_stream.position)
	return positions

func water_streams() -> Array[WaterStream]:
	return _water_streams

func add_character(character: Character) -> void:
	_characters.append(character)

func character_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for character in _characters:
		positions.append(character.position())
	return positions

func characters() -> Array[Character]:
	return _characters

func check_trap_character_in_bubble(cell: Vector2i) -> void:
	for character in _characters:
		if character.is_trapped():
			continue
		if abs(character.continuous_position.x - cell.x) < TRAP_MARGIN and abs(character.continuous_position.y - cell.y) < TRAP_MARGIN:
			character.trapped()

func has_character(position: Vector2i) -> bool:
	return character_positions().has(position)

func _remove_character(character: Character) -> void:
	_characters.erase(character)

func check_pop_water_balloons() -> Array[WaterBalloon]:
	var popped_water_balloons: Array[WaterBalloon] = []
	for water_balloon: WaterBalloon in _water_balloons.values():
		if water_balloon.position in water_stream_positions():
			_remove_water_balloon(water_balloon.position)
			popped_water_balloons.append(water_balloon)
	return popped_water_balloons

func let_character_out(character: Character) -> void:
	character.out()
	_remove_character(character)

func game_items_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for game_item in _game_items:
		positions.append(game_item.position)
	return positions

func add_game_item(type: int, cell: Vector2i) -> bool:
	if game_items_positions().has(cell):
		return false
	var game_item := GameItem.new(type, cell)
	_game_items.append(game_item)
	return true

func _remove_game_item(game_item: GameItem) -> void:
	_game_items.erase(game_item)

func game_items() -> Array[GameItem]:
	return _game_items

func has_game_item(cell: Vector2i) -> bool:
	return game_items_positions().has(cell)

func water_balloon_count_by_character(character: Character) -> int:
	var count := 0
	for water_balloon in _water_balloons.values():
		if water_balloon.placed_by == character:
			count += 1
	return count
