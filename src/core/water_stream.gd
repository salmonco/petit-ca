class_name WaterStream
extends RefCounted

const DURATION := 1.0
const DIRECTION: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var _elapsed_time: float
var position: Vector2i
var direction: Vector2i
var position_type: String # "center" | "straight" | "end"

func _init(cell: Vector2i, dir: Vector2i, type: String) -> void:
	position = cell
	direction = dir
	position_type = type

func tick(delta: float) -> bool:
	_elapsed_time += delta
	return _elapsed_time >= DURATION
