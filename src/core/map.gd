class_name Map
extends RefCounted

const GRID_SIZE := Vector2i(15, 13)
const PIXELS_PER_CELL := 64

var _characters: Array[Character] = []
var _water_balloons: Dictionary[Vector2i, WaterBalloon] = {}
var _water_streams: Array[WaterStream] = []

static func to_pixel(grid: Vector2i) -> Vector2:
	return Vector2(grid) * PIXELS_PER_CELL

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
	var new_water_streams: Array[WaterStream] = []
	for water_balloon: WaterBalloon in _water_balloons.values():
		if water_balloon.tick(delta):
			_remove_water_balloon(water_balloon.position)
			var water_stream := WaterStream.new(water_balloon.position)
			new_water_streams.append(water_stream)
	
	var expired_water_streams: Array[WaterStream] = []
	for water_stream: WaterStream in _water_streams:
		if water_stream.tick(delta):
			expired_water_streams.append(water_stream)
	for water_stream: WaterStream in expired_water_streams:
		_remove_water_stream(water_stream)

	for new_water_stream in new_water_streams:
		add_water_stream(new_water_stream)

func add_water_stream(water_stream: WaterStream) -> bool:
	_water_streams.append(water_stream)
	return true

func _remove_water_stream(water_stream: WaterStream) -> void:
	_water_streams.erase(water_stream)

func has_water_stream(position: Vector2i) -> bool:
	return water_stream_positions().has(position)

func water_stream_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for water_stream in _water_streams:
		for cell in water_stream.positions():
			positions.append(cell)
	return positions

func add_character(character: Character) -> void:
	_characters.append(character)

func character_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for character in _characters:
		positions.append(character.position)
	return positions

func is_character_trapped(position: Vector2i) -> bool:
	if character_positions().has(position) and water_stream_positions().has(position):
		return true
	return false

func characters() -> Array[Character]:
	return _characters