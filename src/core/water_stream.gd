class_name WaterStream
extends RefCounted

const DURATION := 1.0

var _elapsed_time: float
var _center_position: Vector2i

func _init(center_position: Vector2i) -> void:
	_center_position = center_position

func tick(delta: float) -> bool:
	_elapsed_time += delta
	return _elapsed_time >= DURATION