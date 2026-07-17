class_name Character
extends RefCounted

var position: Vector2i
var color: Color
var is_trapped: bool = false
var is_out: bool = false
var bubble: Bubble = null

func _init(start_position: Vector2i) -> void:
	position = start_position

func move(direction: Vector2i) -> void:
	var new_position := position + direction
	position = new_position.clamp(Vector2i.ZERO, Map.GRID_SIZE - Vector2i.ONE)

func place_water_balloon(map: Map) -> bool:
	var water_balloon := WaterBalloon.new(position)
	return map.add_water_balloon(water_balloon)

func trapped() -> void:
	bubble = Bubble.new()
	is_trapped = true

func out() -> void:
	bubble = null
	is_out = true
	is_trapped = false