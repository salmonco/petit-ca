class_name CharacterView
extends AnimatedSprite2D

func sync(character: Character) -> void:
	position = character.pixel_position()
	if character.is_trapped():
		play("bubble")
		return
	match character.facing:
		Vector2i.UP:
			play("walk_up")
		Vector2i.DOWN:
			play("walk_down")
		Vector2i.LEFT:
			play("walk_side")
			flip_h = true
		Vector2i.RIGHT:
			play("walk_side")
			flip_h = false
	return
