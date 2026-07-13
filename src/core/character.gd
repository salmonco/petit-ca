class_name Character
extends RefCounted

var position: Vector2i

func _init(start_position: Vector2i) -> void:
	position = start_position

func move(direction: Vector2i) -> void:
	position = position + direction


