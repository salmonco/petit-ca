extends GdUnitTestSuite

func test_키보드_위쪽_방향키를_누르면_위쪽_방향을_가리킨다() -> void:
	assert_vector(Direction.from_key(KEY_UP)).is_equal(Vector2i.UP)

func test_키보드_아래쪽_방향키를_누르면_아래쪽_방향을_가리킨다() -> void:
	assert_vector(Direction.from_key(KEY_DOWN)).is_equal(Vector2i.DOWN)

func test_키보드_왼쪽_방향키를_누르면_왼쪽_방향을_가리킨다() -> void:
	assert_vector(Direction.from_key(KEY_LEFT)).is_equal(Vector2i.LEFT)

func test_키보드_오른쪽_방향키를_누르면_오른쪽_방향을_가리킨다() -> void:
	assert_vector(Direction.from_key(KEY_RIGHT)).is_equal(Vector2i.RIGHT)

func test_방향키가_아닌_키를_누르면_방향을_가리키지_않는다() -> void:
	assert_vector(Direction.from_key(KEY_SPACE)).is_equal(Vector2i.ZERO)
