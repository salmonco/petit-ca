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
const TRAP_REACH_SIDE := 0.35
const TRAP_REACH_TOP := 0.68
const TRAP_REACH_BOTTOM := 0.16

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

func can_trap(continuous_position: Vector2) -> bool:
	var offset := continuous_position - Vector2(position)
	for rect in _trap_rects():
		if rect.has_point(offset):
			return true
	return false

func _trap_rects() -> Array[Rect2]:
	match position_type:
		"center": return [_arm_rect(Vector2i.RIGHT, false), _arm_rect(Vector2i.DOWN, false)]
		"straight": return [_arm_rect(direction, false)]
		"end":      return [_arm_rect(direction, true)]
	return []

func _arm_rect(axis: Vector2i, is_end: bool) -> Rect2:
	var left := _reach(Vector2i.LEFT, axis, is_end)
	var top := _reach(Vector2i.UP, axis, is_end)
	var right := _reach(Vector2i.RIGHT, axis, is_end)
	var bottom := _reach(Vector2i.DOWN, axis, is_end)
	return Rect2(Vector2(-left, -top), Vector2(left + right, top + bottom))

func _reach(face: Vector2i, axis: Vector2i, is_end: bool) -> float:
	if face == -axis:
		# 중심을 향하는 면 - 언제나 이어짐
		return HALF_CELL 
	if face == axis and not is_end:
		# 뻗어 나가는 면 - 끝 칸이 아니면 이어짐
		return HALF_CELL
	return _exposed_reach(face)

static func _exposed_reach(face: Vector2i) -> float:
	match face:
		Vector2i.UP: return TRAP_REACH_TOP
		Vector2i.DOWN: return TRAP_REACH_BOTTOM
	return TRAP_REACH_SIDE
