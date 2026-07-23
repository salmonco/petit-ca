class_name Battle
extends RefCounted

var _map: Map

func _init(map: Map) -> void:
	_map = map

func is_game_over() -> bool:
	var humans: Array[Character] = []
	var npcs: Array[Npc] = []
	for character in _map.characters():
		if character is Npc:
			npcs.append(character)
		else:
			humans.append(character)
	return humans.is_empty() or npcs.is_empty()

func is_win() -> bool:
	var humans: Array[Character] = []
	var npcs: Array[Npc] = []
	for character in _map.characters():
		if character is Npc:
			npcs.append(character)
		else:
			humans.append(character)
	return not humans.is_empty() and npcs.is_empty()

func is_lose() -> bool:
	var humans: Array[Character] = []
	var npcs: Array[Npc] = []
	for character in _map.characters():
		if character is Npc:
			npcs.append(character)
		else:
			humans.append(character)
	return not npcs.is_empty() and humans.is_empty()

func is_draw() -> bool:
	var humans: Array[Character] = []
	var npcs: Array[Npc] = []
	for character in _map.characters():
		if character is Npc:
			npcs.append(character)
		else:
			humans.append(character)
	return humans.is_empty() and npcs.is_empty()