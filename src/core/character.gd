class_name Character
extends RefCounted

const SPEED := 4.0

var continous_position: Vector2
var color: Color
var is_trapped: bool = false
var is_out: bool = false
var bubble: Bubble = null

func _init(start_position: Vector2i) -> void:
	continous_position = start_position

func move(direction: Vector2i, delta: float) -> void:
	var new_position := continous_position + direction * SPEED * delta
	continous_position = new_position.clamp(Vector2i.ZERO, Map.GRID_SIZE - Vector2i.ONE)

func place_water_balloon(map: Map) -> bool:
	var water_balloon := WaterBalloon.new(position())
	return map.add_water_balloon(water_balloon)

func trapped() -> void:
	bubble = Bubble.new()
	is_trapped = true

func out() -> void:
	bubble = null
	is_out = true
	is_trapped = false

func position() -> Vector2i:
	return Vector2i(continous_position.round())

func pixel_position() -> Vector2:
	return continous_position * Map.PIXELS_PER_CELL