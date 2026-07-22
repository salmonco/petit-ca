class_name Npc
extends Character

func decide_move_direction(map: Map) -> Vector2i:
	var target: Character
	for character in map.characters():
		if character != self:
			target = character
			break
	if target == null:
		return Vector2i.ZERO
	var delta_x: float = continuous_position.x - target.continuous_position.x
	var delta_y: float = continuous_position.y - target.continuous_position.y
	if abs(delta_x) > abs(delta_y):
		if delta_x > 0:
			return Vector2i.LEFT
		return Vector2i.RIGHT
	if delta_y > 0:
		return Vector2i.UP
	return Vector2i.DOWN