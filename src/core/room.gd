class_name Room
extends RefCounted

const MINIMUM_TEAM_COUNT_TO_START_GAME := 2

var _characters: Array[Character] = []
var _battle: Battle
var id: String
var battle_mode: StringName = BattleMode.LOCAL_MULTI

func _init() -> void:
	id = UUID.v4()

func add_character(character: Character) -> void:
	_characters.append(character)
	character.joined_room_id = id

func game_start() -> void:
	var map := Map.new()
	for character in _characters:
		map.add_character(character)
	_battle = Battle.new(map, battle_mode)

func get_battle() -> Battle:
	return _battle

func set_battle_mode(mode: StringName) -> void:
	battle_mode = mode
	if mode == BattleMode.MONSTER:
		_add_npc()
	else:
		if has_npc():
			_remove_npcs()

func remove_character(character: Character) -> void:
	_characters.erase(character)
	character.joined_room_id = ""

func characters() -> Array[Character]:
	return _characters

func team_count() -> int:
	return Team.colors(_characters).size()

func can_game_start() -> bool:
	return team_count() >= MINIMUM_TEAM_COUNT_TO_START_GAME

func has_npc() -> bool:
	for character in _characters:
		if character is Npc:
			return true
	return false

func _remove_npcs() -> void:
	for character in _characters.duplicate():
		if character is Npc:
			_characters.erase(character)

func _add_npc() -> void:
	var npc := Npc.new(Vector2i(2, 3), 0, Team.MONSTER_COLOR)
	add_character(npc)
