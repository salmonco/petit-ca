class_name WaterBalloon
extends RefCounted

const POP_AFTER_SECONDS := 3.0

var _elapsed_seconds: float
var position: Vector2i
var placed_by: Character
var stream_length: int

func _init(placed_position: Vector2i, character: Character) -> void:
	position = placed_position
	placed_by = character
	stream_length = character.max_water_stream_length

func tick(delta: float) -> bool:
	_elapsed_seconds += delta
	return _elapsed_seconds >= POP_AFTER_SECONDS
