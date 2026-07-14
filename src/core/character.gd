class_name Character
extends RefCounted

var _map: Map
var position: Vector2i

func _init(start_position: Vector2i, map: Map) -> void:
	_map = map
	position = start_position

func move(direction: Vector2i) -> void:
	var new_position := position + direction
	position = new_position.clamp(Vector2i.ZERO, Map.GRID_SIZE - Vector2i.ONE)

func place_water_balloon() -> void:
	var water_balloon := WaterBalloon.new(position)
	_map.add_water_balloon(water_balloon)
	