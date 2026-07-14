class_name WaterBalloon
extends RefCounted

var position: Vector2i

func _init(placed_position: Vector2i) -> void:
	position = placed_position
	