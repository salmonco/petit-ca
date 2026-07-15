extends GdUnitTestSuite

func test_캐릭터가_위쪽_방향으로_움직인다() -> void:
	var character := Character.new(Vector2i.ONE)
	character.move(Vector2i.UP)
	assert_vector(character.position).is_equal(Vector2i(1, 0))

func test_캐릭터가_아래쪽_방향으로_움직인다() -> void:
	var character := Character.new(Vector2i.ONE)
	character.move(Vector2i.DOWN)
	assert_vector(character.position).is_equal(Vector2i(1, 2))

func test_캐릭터가_왼쪽_방향으로_움직인다() -> void:
	var character := Character.new(Vector2i.ONE)
	character.move(Vector2i.LEFT)
	assert_vector(character.position).is_equal(Vector2i(0, 1))

func test_캐릭터가_오른쪽_방향으로_움직인다() -> void:
	var character := Character.new(Vector2i.ONE)
	character.move(Vector2i.RIGHT)
	assert_vector(character.position).is_equal(Vector2i(2, 1))

# 맵 밖으로 이동 제한
func test_캐릭터는_위쪽_맵_밖으로_이동하지_못한다() -> void:
	var character := Character.new(Vector2i(1, 0))
	character.move(Vector2i.UP)
	assert_vector(character.position).is_equal(Vector2i(1, 0))

func test_캐릭터는_아래쪽_맵_밖으로_이동하지_못한다() -> void:
	var bottom_row := Map.GRID_SIZE.y - 1
	var character := Character.new(Vector2i(1, bottom_row))
	character.move(Vector2i.DOWN)
	assert_vector(character.position).is_equal(Vector2i(1, bottom_row))

func test_캐릭터는_왼쪽_맵_밖으로_이동하지_못한다() -> void:
	var character := Character.new(Vector2i(0, 1))
	character.move(Vector2i.LEFT)
	assert_vector(character.position).is_equal(Vector2i(0, 1))

func test_캐릭터는_오른쪽_맵_밖으로_이동하지_못한다() -> void:
	var right_column := Map.GRID_SIZE.x - 1
	var character := Character.new(Vector2i(right_column, 1))
	character.move(Vector2i.RIGHT)
	assert_vector(character.position).is_equal(Vector2i(right_column, 1))

# 물풍선 놓기
func test_캐릭터는_물풍선을_놓을_수_있다() -> void:
	var map := Map.new()
	var character := Character.new(Vector2i(1, 0))
	var is_placed := character.place_water_balloon(map)
	assert_bool(is_placed).is_true()

func test_캐릭터는_물풍선이_있는_칸에_또_물풍선을_놓을_수_없다() -> void:
	var map := Map.new()
	var character := Character.new(Vector2i(1, 0))
	character.place_water_balloon(map)
	var is_placed := character.place_water_balloon(map)
	assert_bool(is_placed).is_false()
