class_name Map

const GRID_SIZE := Vector2i(15, 13)
const PIXELS_PER_CELL := 64

static func to_pixel(grid: Vector2i) -> Vector2:
	return Vector2(grid) * PIXELS_PER_CELL
