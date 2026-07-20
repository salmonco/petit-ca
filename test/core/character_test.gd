extends GdUnitTestSuite

# 맵 밖으로 이동 제한
func test_캐릭터는_위쪽_맵_밖으로_이동하지_못한다() -> void:
	var character := Character.new(Vector2i(1, 0))
	character.move(Vector2i.UP, 1.0, [])
	assert_vector(character.position()).is_equal(Vector2i(1, 0))

func test_캐릭터는_아래쪽_맵_밖으로_이동하지_못한다() -> void:
	var bottom_row := Map.GRID_SIZE.y - 1
	var character := Character.new(Vector2i(1, bottom_row))
	character.move(Vector2i.DOWN, 1.0, [])
	assert_vector(character.position()).is_equal(Vector2i(1, bottom_row))

func test_캐릭터는_왼쪽_맵_밖으로_이동하지_못한다() -> void:
	var character := Character.new(Vector2i(0, 1))
	character.move(Vector2i.LEFT, 1.0, [])
	assert_vector(character.position()).is_equal(Vector2i(0, 1))

func test_캐릭터는_오른쪽_맵_밖으로_이동하지_못한다() -> void:
	var right_column := Map.GRID_SIZE.x - 1
	var character := Character.new(Vector2i(right_column, 1))
	character.move(Vector2i.RIGHT, 1.0, [])
	assert_vector(character.position()).is_equal(Vector2i(right_column, 1))

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

# 물방울에 갇힘
func test_물줄기가_있는_동안에_캐릭터가_물줄기_위치에_있으면_물방울에_갇힌다() -> void:
	var map := Map.new()
	var water_stream := WaterStream.new(Vector2i(3, 4))
	map.add_water_stream(water_stream)
	var character := Character.new(Vector2i(3, 4))
	map.add_character(character)
	map.tick(WaterStream.DURATION * 0.5)
	assert_bool(character.is_trapped).is_true()

func test_물줄기가_있는_동안에_캐릭터가_물줄기_위치에_있지_않으면_물방울에_갇히지_않는다() -> void:
	var map := Map.new()
	var water_stream := WaterStream.new(Vector2i(3, 4))
	map.add_water_stream(water_stream)
	var character := Character.new(Vector2i(2, 3))
	map.add_character(character)
	map.tick(WaterStream.DURATION * 0.5)
	assert_bool(character.is_trapped).is_false()

func test_물줄기가_있는_동안에_캐릭터가_이전_물줄기_위치로_이동하면_물방울에_갇힌다() -> void:
	var map := Map.new()
	var water_stream := WaterStream.new(Vector2i(2, 3))
	map.add_water_stream(water_stream)
	var character := Character.new(Vector2i(1, 2))
	map.add_character(character)
	map.tick(WaterStream.DURATION * 0.5)
	character.move(Vector2i.RIGHT, 0.25, [])
	map.tick(0.1)
	assert_bool(character.is_trapped).is_true()

func test_물줄기가_사라진_후에_캐릭터가_이전_물줄기_위치로_이동하면_물방울에_갇히지_않는다() -> void:
	var map := Map.new()
	var water_stream := WaterStream.new(Vector2i(2, 3))
	map.add_water_stream(water_stream)
	var character := Character.new(Vector2i(1, 2))
	map.add_character(character)
	map.tick(WaterStream.DURATION * 1.5)
	character.move(Vector2i.RIGHT, 0.25, [])
	map.tick(0.1)
	assert_bool(character.is_trapped).is_false()

# 자동 아웃
func test_캐릭터가_물방울에_갇히고_일정_시간이_지나면_자동_아웃된다() -> void:
	var map := Map.new()
	var water_stream := WaterStream.new(Vector2i(2, 3))
	map.add_water_stream(water_stream)
	var character := Character.new(Vector2i(2, 3))
	map.add_character(character)
	map.tick(WaterStream.DURATION * 0.5)
	assert_bool(character.is_out).is_false()
	map.tick(WaterStream.DURATION * 0.5)
	assert_bool(character.is_out).is_false()
	map.tick(Bubble.ALIVE_SECONDS * 0.5)
	assert_bool(character.is_out).is_false()
	map.tick(Bubble.ALIVE_SECONDS * 1.5)
	assert_bool(character.is_out).is_true()

# 걸치기
func test_캐릭터는_격자_사이를_걸쳐서_움직일_수_있다() -> void:
	var character := Character.new(Vector2i(3, 2))
	character.move(Vector2i.RIGHT, 0.1, [])
	assert_bool(character.position() != Vector2i(4, 2)).is_true()

func test_캐릭터의_격자_위치는_연속된_위치로부터_파생한다() -> void:
	var character := Character.new(Vector2i(3, 2))
	character.move(Vector2i.RIGHT, 0.15, [])
	assert_vector(character.position()).is_equal(Vector2i(4, 2))

# 가두기
func test_캐릭터는_다른_칸에_있는_물풍선_위치로_이동할_수_없다() -> void:
	var map := Map.new()
	var character := Character.new(Vector2i(3, 4))
	var water_balloon := WaterBalloon.new(Vector2i(4, 4))
	map.add_character(character)
	map.add_water_balloon(water_balloon)
	assert_bool(character.move(Vector2i.RIGHT, 0.25, map.water_balloon_positions())).is_false()

func test_캐릭터는_물풍선이_없는_칸으로_이동할_수_있다() -> void:
	var map := Map.new()
	var character := Character.new(Vector2i(3, 4))
	var water_balloon := WaterBalloon.new(Vector2i(3, 3))
	map.add_character(character)
	map.add_water_balloon(water_balloon)
	assert_bool(character.move(Vector2i.RIGHT, 0.25, map.water_balloon_positions())).is_true()

func test_캐릭터는_물풍선을_놓고_나서_바로_이동할_수_있다() -> void:
	var map := Map.new()
	var character := Character.new(Vector2i(3, 4))
	map.add_character(character)
	character.place_water_balloon(map)
	assert_bool(character.move(Vector2i.RIGHT, 0.1, map.water_balloon_positions())).is_true()