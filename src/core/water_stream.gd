class_name WaterStream
extends RefCounted

const DURATION := 1.0
const DIRECTION: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]
const HALF_CELL := 0.5
const TRAP_REACH_EXPOSED := 0.3

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

func can_trap(character_box: Rect2) -> bool:
	for rect in _trap_rects():
		if rect.intersects(character_box):
			return true
	return false

func _trap_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	match position_type:
		"center":
			rects.append(_arm_rect(Vector2i.RIGHT, false))
			rects.append(_arm_rect(Vector2i.DOWN, false))
		"straight":
			rects.append(_arm_rect(direction, false))
		"end":
			rects.append(_arm_rect(direction, true))
	return rects

func _arm_rect(axis: Vector2i, is_end: bool) -> Rect2:
	var left := _reach(Vector2i.LEFT, axis, is_end)
	var top := _reach(Vector2i.UP, axis, is_end)
	var right := _reach(Vector2i.RIGHT, axis, is_end)
	var bottom := _reach(Vector2i.DOWN, axis, is_end)
	return Rect2(Vector2(position) + Vector2(-left, -top), Vector2(left + right, top + bottom))

func _reach(face: Vector2i, axis: Vector2i, is_end: bool) -> float:
	if face == -axis:
		# 중심을 향하는 면 - 언제나 이어짐
		return HALF_CELL
	if face == axis and not is_end:
		# 뻗어 나가는 면 - 끝 칸이 아니면 이어짐
		return HALF_CELL
	return TRAP_REACH_EXPOSED
