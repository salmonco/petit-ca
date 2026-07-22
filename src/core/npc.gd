class_name Npc
extends Character

func decide_move_direction(map: Map) -> Vector2i:
	var character_position := map.characters()[0].continuous_position
	var delta_x: float = continuous_position.x - character_position.x
	var delta_y: float = continuous_position.y - character_position.y
	if abs(delta_x) > abs(delta_y):
		if delta_x > 0:
			return Vector2i.LEFT
		return Vector2i.RIGHT
	if delta_y > 0:
		return Vector2i.UP
	return Vector2i.DOWN