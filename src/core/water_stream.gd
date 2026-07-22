class_name WaterStream
extends RefCounted

const DURATION := 1.0
const DIRECTION: Array[Vector2i] = [
	Vector2i.ZERO,
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var _elapsed_time: float
var position: Vector2i
var direction: Vector2i

func _init(cell: Vector2i, dir: Vector2i) -> void:
	position = cell
	direction = dir

func tick(delta: float) -> bool:
	_elapsed_time += delta
	return _elapsed_time >= DURATION
