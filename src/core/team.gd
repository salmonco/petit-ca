class_name Team
extends RefCounted

static func colors(characters: Array[Character]) -> Array[Color]:
	var team: Array[Color] = []
	for character in characters:
		var color = character.color
		if color not in team:
			team.append(color)
	return team
