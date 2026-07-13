extends GdUnitTestSuite

func test_캐릭터를_방향키로_움직일_수_있다() -> void:
	var character := Character.new(Vector2i.ZERO)

	character.move(Vector2i.UP)
	assert_vector(character.position).is_equal(Vector2i(0, -1))

	character.move(Vector2i.RIGHT)
	assert_vector(character.position).is_equal(Vector2i(1, -1))

	character.move(Vector2i.DOWN)
	assert_vector(character.position).is_equal(Vector2i(1, 0))

	character.move(Vector2i.LEFT)
	assert_vector(character.position).is_equal(Vector2i(0, 0))
