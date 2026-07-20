class_name Character
extends RefCounted

const SPEED := 4.0

var continous_position: Vector2
var color: Color
var is_out: bool = false
var bubble: Bubble = null

func _init(start_position: Vector2i) -> void:
	continous_position = start_position

func move(direction: Vector2i, delta: float, water_balloon_positions: Array[Vector2i]) -> bool:
	var water_balloon_positions_except_character_position: Array[Vector2i] = []
	for cell in water_balloon_positions:
		if cell != position():
			water_balloon_positions_except_character_position.append(cell)
	
	var new_position := continous_position + direction * SPEED * delta
	var clamped_position := new_position.clamp(Vector2i.ZERO, Map.GRID_SIZE - Vector2i.ONE)
	var cell := Vector2i(clamped_position.round())
	if water_balloon_positions_except_character_position.has(cell):
		return false
	continous_position = clamped_position
	return true

func place_water_balloon(map: Map) -> bool:
	var water_balloon := WaterBalloon.new(position())
	return map.add_water_balloon(water_balloon)

func trapped() -> void:
	bubble = Bubble.new()

func out() -> void:
	bubble = null
	is_out = true

func position() -> Vector2i:
	return Vector2i(continous_position.round())

func pixel_position() -> Vector2:
	return continous_position * Map.PIXELS_PER_CELL

func is_trapped() -> bool:
	return bubble != null