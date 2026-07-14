class_name Character
extends RefCounted

var position: Vector2i

func _init(start_position: Vector2i) -> void:
	position = start_position

func move(direction: Vector2i) -> void:
	var new_position := position + direction
	position = new_position.clamp(Vector2i.ZERO, Map.GRID_SIZE - Vector2i.ONE)
