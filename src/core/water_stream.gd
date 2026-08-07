class_name WaterStream
extends RefCounted

const DURATION := 1.0
const DIRECTION: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]
const TRAP_MARGIN := 0.35
const HALF_CELL := 0.5

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

func is_in(continuous_position: Vector2) -> bool:
	var offset := continuous_position - Vector2(position)
	match position_type:
		"center":
			return _is_in_arm(offset, Vector2i.RIGHT, HALF_CELL) \
				or _is_in_arm(offset, Vector2i.DOWN, HALF_CELL)
		"straight":
			return _is_in_arm(offset, direction, HALF_CELL)
		"end":
			return _is_in_arm(offset, direction, TRAP_MARGIN)
	return false

func _is_in_arm(offset: Vector2, axis: Vector2i, outward: float) -> bool:
	var along := offset.dot(Vector2(axis))
	var across := offset.dot(Vector2(axis).orthogonal())
	return along >= -HALF_CELL and along < outward and absf(across) < TRAP_MARGIN
