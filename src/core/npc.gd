class_name Npc
extends Character

func decide_move_direction(map: Map) -> Vector2i:
	var chase_direction: Vector2i
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
			chase_direction = Vector2i.LEFT
		else:
			chase_direction = Vector2i.RIGHT
	else:
		if delta_y > 0:
			chase_direction = Vector2i.UP
		else:
			chase_direction = Vector2i.DOWN
	
	if position() in map.water_balloon_positions():
		return -chase_direction
	return chase_direction

func should_place_water_balloon(map: Map) -> bool:
	var target: Character
	for character in map.characters():
		if character != self:
			target = character
			break
	if target == null:
		return false
	var delta_x: int = position().x - target.position().x
	var delta_y: int = position().y - target.position().y
	if abs(delta_x) <= 1 and abs(delta_y) <= 1:
		return true
	return false