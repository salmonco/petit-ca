class_name WaterStream
extends RefCounted

const DURATION := 1.0
const _DIRECTION: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var _elapsed_time: float
var center_position: Vector2i

func _init(balloon_position: Vector2i) -> void:
	center_position = balloon_position

func tick(delta: float) -> bool:
	_elapsed_time += delta
	return _elapsed_time >= DURATION

func positions() -> Array[Vector2i]:
	var cells: Array[Vector2i] = [center_position]
	for direction in _DIRECTION:
		cells.append(center_position + direction)
	return cells