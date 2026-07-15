class_name WaterBalloon
extends RefCounted

const POP_AFTER_SECONDS := 3.0

var _elapsed_seconds: float
var position: Vector2i

func _init(placed_position: Vector2i) -> void:
	position = placed_position

func tick(delta: float) -> bool:
	_elapsed_seconds += delta
	return _elapsed_seconds >= POP_AFTER_SECONDS

func has_water_stream() -> bool:
	return _elapsed_seconds == POP_AFTER_SECONDS

func water_stream_positions() -> Array[Vector2i]:
	return [position + Vector2i.UP, position + Vector2i.DOWN, position + Vector2i.LEFT, position + Vector2i.RIGHT]
