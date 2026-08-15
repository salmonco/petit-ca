extends GdUnitTestSuite

func test_캐릭터의_색상으로_팀을_나눈다() -> void:
	var characters: Array[Character] = []
	var character1 := Character.new(Vector2i(4, 2), 1, Color.RED)
	var character2 := Character.new(Vector2i(9, 10), 2, Color.BLUE)
	characters.append(character1)
	characters.append(character2)
	assert_array(Team.colors(characters)).is_equal([Color.RED, Color.BLUE])
	var character3 := Character.new(Vector2i(9, 10), 2, Color.ORANGE)
	characters.append(character3)
	assert_array(Team.colors(characters)).is_equal([Color.RED, Color.BLUE, Color.ORANGE])
	var character4 := Character.new(Vector2i(9, 10), 2, Color.RED)
	characters.append(character4)
	assert_array(Team.colors(characters)).is_equal([Color.RED, Color.BLUE, Color.ORANGE])
