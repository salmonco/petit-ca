class_name Battle
extends RefCounted

var winner: Color = Color.BLACK
var is_draw: bool = false
var _map: Map
var _mode: StringName

func _init(map: Map, mode: StringName) -> void:
	_map = map
	_mode = mode

func tick(delta: float) -> void:
	_map.tick(delta)
	if not is_game_over():
		check_game_over()

func is_game_over() -> bool:
	return has_winner() or is_draw

func check_game_over() -> void:
	if _team_count() == 1:
		winner = Team.colors(_map.characters())[0]
	if _team_count() == 0:
		is_draw = true

func _team_count() -> int:
	return Team.colors(_map.characters()).size()

func has_winner() -> bool:
	return winner != Color.BLACK

func get_map() -> Map:
	return _map

func get_mode() -> StringName:
	return _mode

func set_mode(mode: StringName) -> void:
	_mode = mode
