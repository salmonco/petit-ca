extends GdUnitTestSuite

func test_키보드_위쪽_방향키를_벡터로_변환한다() -> void:
	assert_vector(Direction.from_key(KEY_UP)).is_equal(Vector2i.UP)

func test_키보드_아래쪽_방향키를_벡터로_변환한다() -> void:
	assert_vector(Direction.from_key(KEY_DOWN)).is_equal(Vector2i.DOWN)

func test_키보드_왼쪽_방향키를_벡터로_변환한다() -> void:
	assert_vector(Direction.from_key(KEY_LEFT)).is_equal(Vector2i.LEFT)

func test_키보드_오른_방향키를_벡터로_변환한다() -> void:
	assert_vector(Direction.from_key(KEY_RIGHT)).is_equal(Vector2i.RIGHT)
