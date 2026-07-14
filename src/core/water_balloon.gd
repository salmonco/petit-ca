class_name WaterBalloon
extends RefCounted

const POP_AFTER_SECONDS := 3.0

var position: Vector2i
var _elapsed_seconds: float

func _init(placed_position: Vector2i) -> void:
	position = placed_position

func tick(delta: float) -> bool:
	_elapsed_seconds += delta
	return _elapsed_seconds >= POP_AFTER_SECONDS
