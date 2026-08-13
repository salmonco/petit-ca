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

func _teams() -> Array[Color]:
	var colors: Array[Color] = []
	for character in _characters:
		var color = character.color
		if color not in colors:
			colors.append(color)
	return colors

func team_count() -> int:
	return _teams().size()

func can_game_start() -> bool:
	return team_count() >= MINIMUM_TEAM_COUNT_TO_START_GAME