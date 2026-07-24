class_name GameItem
extends RefCounted

const INCREASE_WATER_BALLOON_COUNT := 1
const INCREASE_WATER_STREAM_LENGTH := 2

var type: int
var position: Vector2i

func _init(item_type: int, cell: Vector2i) -> void:
	type = item_type
	position = cell