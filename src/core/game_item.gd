class_name GameItem
extends RefCounted

const INCREASE_WATER_BALLOON_COUNT := &"INCREASE_WATER_BALLOON_COUNT"
const INCREASE_WATER_STREAM_LENGTH := &"INCREASE_WATER_STREAM_LENGTH"
const INCREASE_SPEED := &"INCREASE_SPEED"

var type: StringName
var position: Vector2i

func _init(item_type: StringName, cell: Vector2i) -> void:
	type = item_type
	position = cell
