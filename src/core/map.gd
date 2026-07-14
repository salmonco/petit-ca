class_name Map
extends RefCounted

const GRID_SIZE := Vector2i(15, 13)
const PIXELS_PER_CELL := 64

var _water_balloons: Dictionary[Vector2i, WaterBalloon] = {}

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

func tick(delta: float) -> Array[WaterBalloon]:
	var popped: Array[WaterBalloon] = []
	for water_balloon: WaterBalloon in _water_balloons.values():
		if water_balloon.tick(delta):
			popped.append(water_balloon)
			_remove_water_balloon(water_balloon.position)
	return popped
