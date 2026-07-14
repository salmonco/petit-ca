class_name Map

const GRID_SIZE := Vector2i(15, 13)
const PIXELS_PER_CELL := 64

var water_balloon_grid: Dictionary = {}

static func to_pixel(grid: Vector2i) -> Vector2:
	return Vector2(grid) * PIXELS_PER_CELL

func add_water_balloon(water_balloon: WaterBalloon) -> void:
	var position := water_balloon.position
	water_balloon_grid.set(position, water_balloon)

func has_water_balloon(position: Vector2i) -> bool:
	return water_balloon_grid.has(position)

func water_balloon_count() -> int:
	return water_balloon_grid.size()
