class_name Battle
extends RefCounted

var _map: Map

func _init(map: Map) -> void:
	_map = map

func is_game_over() -> bool:
	return not _has_human() or not _has_npc()

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