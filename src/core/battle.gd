class_name Battle
extends RefCounted

var result_type: String = "" # "win" | "lose" | "draw"
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
	return result_type != ""

func check_game_over() -> void:
	if is_win():
		result_type = "win"
	if is_lose():
		result_type = "lose"
	if is_draw():
		result_type = "draw"

func is_win() -> bool:
	return _has_human() and not _has_npc()

func is_lose() -> bool:
	return _has_npc() and not _has_human()

func is_draw() -> bool:
	return not _has_human() and not _has_npc()

func _has_human() -> bool:
	var humans: Array[Character] = []
	for character in _map.characters():
		if character is not Npc:
			humans.append(character)
	return not humans.is_empty()

func _has_npc() -> bool:
	var npcs: Array[Npc] = []
	for character in _map.characters():
		if character is Npc:
			npcs.append(character)
	return not npcs.is_empty()

func get_map() -> Map:
	return _map

func get_mode() -> StringName:
	return _mode
