extends GdUnitTestSuite

var character: Character

func before_test() -> void:
	character = Character.new(Vector2i.ZERO)

func test_캐릭터가_위쪽_방향으로_움직인다() -> void:
	character.move(Vector2i.UP)
	assert_vector(character.position).is_equal(Vector2i.UP)

func test_캐릭터가_아래쪽_방향으로_움직인다() -> void:
	character.move(Vector2i.DOWN)
	assert_vector(character.position).is_equal(Vector2i.DOWN)

func test_캐릭터가_왼쪽_방향으로_움직인다() -> void:
	character.move(Vector2i.LEFT)
	assert_vector(character.position).is_equal(Vector2i.LEFT)

func test_캐릭터가_오른쪽_방향으로_움직인다() -> void:
	character.move(Vector2i.RIGHT)
	assert_vector(character.position).is_equal(Vector2i.RIGHT)
