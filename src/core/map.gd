class_name Map

const CELL_SIZE := 64

static func to_pixel(grid: Vector2i) -> Vector2:
	return Vector2(grid) * CELL_SIZE
