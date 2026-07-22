extends GdUnitTestSuite

var _map: Map

func before_test() -> void:
	_map = Map.new()

func test_그리드를_픽셀로_변환한다() -> void:
	var grid := Vector2i(2, 3)
	assert_vector(Map.to_pixel(grid)).is_equal(Vector2(2 * Map.PIXELS_PER_CELL, 3 * Map.PIXELS_PER_CELL))

func test_그리드가_원점이면_픽셀도_원점을_반환한다() -> void:
	var grid := Vector2i.ZERO
	assert_vector(Map.to_pixel(grid)).is_equal(Vector2.ZERO)

# 물풍선 놓기
func test_캐릭터가_물풍선을_놓으면_맵에_물풍선이_생긴다() -> void:
	var character := Character.new(Vector2i(1, 0))
	character.place_water_balloon(_map)
	assert_bool(_map.has_water_balloon(Vector2i(1, 0))).is_true()

func test_캐릭터가_물풍선이_있는_칸에_또_물풍선을_놓으면_기존_물풍선을_유지한다() -> void:
	var character := Character.new(Vector2i(1, 0))
	character.place_water_balloon(_map)
	character.place_water_balloon(_map)
	assert_int(_map.water_balloon_count()).is_equal(1)

# 물풍선 터지기
func test_터진_물풍선은_맵에서_사라진다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(water_balloon)
	assert_int(_map.water_balloon_count()).is_equal(1)
	_map.tick(4.0)
	assert_int(_map.water_balloon_count()).is_equal(0)

func test_물풍선_중에_안_터진_물풍선은_맵에_남아있다() -> void:
	var old_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(old_balloon)
	_map.tick(2.0)
	var new_balloon := WaterBalloon.new(Vector2i(5, 7))
	_map.add_water_balloon(new_balloon)
	_map.tick(2.0)
	assert_bool(_map.has_water_balloon(Vector2i(4, 2))).is_false()
	assert_bool(_map.has_water_balloon(Vector2i(5, 7))).is_true()

func test_같은_칸에_물풍선을_다시_놓아도_먼저_놓인_물풍선의_시간은_리셋되지_않는다() -> void:
	var old_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(old_balloon)
	_map.tick(2.0)
	var new_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(new_balloon)
	_map.tick(2.0)
	assert_bool(_map.has_water_balloon(Vector2i(4, 2))).is_false()

# 물줄기 생김
func test_물풍선이_터지면_물줄기가_생긴다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(water_balloon)
	_map.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_bool(_map.has_water_stream(Vector2i(4, 2))).is_true()

func test_물풍선은_터지고_나서_제_수명만큼_유지된다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(water_balloon)
	_map.tick(WaterBalloon.POP_AFTER_SECONDS)
	_map.tick(0.4)
	_map.tick(0.4)
	assert_bool(_map.has_water_stream(Vector2i(4, 2))).is_true()

func test_물풍선이_터질_때만_물줄기가_생긴다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(water_balloon)
	_map.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_bool(_map.has_water_stream(Vector2i(4, 2))).is_true()
	_map.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_bool(_map.has_water_stream(Vector2i(4, 2))).is_false()

func test_물풍선_여러_개를_놓으면_터진_물풍선에만_물줄기가_생긴다() -> void:
	var old_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(old_balloon)
	_map.tick(WaterBalloon.POP_AFTER_SECONDS)
	var new_balloon := WaterBalloon.new(Vector2i(6, 8))
	_map.add_water_balloon(new_balloon)
	assert_bool(_map.has_water_stream(Vector2i(4, 2))).is_true()
	assert_bool(_map.has_water_stream(Vector2i(6, 8))).is_false()

func test_물풍선이_터지면_물줄기가_중앙과_상하좌우로_한_칸씩_생긴다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(water_balloon)
	_map.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_array(_map.water_stream_positions()).contains_exactly([Vector2i(4, 2), Vector2i(4, 1), Vector2i(4, 3), Vector2i(3, 2), Vector2i(5, 2)])

# 물방울에 갇힘
func test_캐릭터가_물방울에_갇혀도_맵에_남아있다() -> void:
	var water_stream := WaterStream.new(Vector2i(4, 2), Vector2i.ZERO)
	var character := Character.new(Vector2i(4, 2))
	_map.add_water_stream(water_stream)
	_map.add_character(character)
	_map.tick(0.1)
	assert_bool(_map.has_character(Vector2i(4, 2))).is_true()

func test_물방울에_갇힌_상태의_캐릭터가_물풍선을_놓아도_맵에_물풍선이_추가되지_않는다() -> void:
	var character := Character.new(Vector2i(1, 5))
	character.water_balloon_count = 2
	_map.add_character(character)
	character.place_water_balloon(_map)
	assert_int(_map.water_balloon_count()).is_equal(1)
	character.trapped()
	character.move(Vector2i.DOWN, 0.25, _map.water_balloon_positions())
	_map.tick(0.25)
	character.place_water_balloon(_map)
	assert_int(_map.water_balloon_count()).is_equal(1)

# 자동 아웃
func test_캐릭터가_물방울에_갇힌_후_일정_시간이_지나면_자동_아웃되어_맵에서_사라진다() -> void:
	var water_stream := WaterStream.new(Vector2i(4, 2), Vector2i.ZERO)
	var character := Character.new(Vector2i(4, 2))
	_map.add_water_stream(water_stream)
	_map.add_character(character)
	_map.tick(WaterStream.DURATION * 0.5)
	assert_bool(_map.has_character(Vector2i(4, 2))).is_true()
	_map.tick(Bubble.ALIVE_SECONDS * 1.5)
	assert_bool(_map.has_character(Vector2i(4, 2))).is_false()

# 게임 오버
func test_맵에_캐릭터가_남아있지_않으면_게임을_종료한다() -> void:
	var water_stream := WaterStream.new(Vector2i(4, 2), Vector2i.ZERO)
	var character := Character.new(Vector2i(4, 2))
	_map.add_water_stream(water_stream)
	_map.add_character(character)
	_map.tick(WaterStream.DURATION * 0.5)
	assert_bool(_map.is_game_over()).is_false()
	_map.tick(Bubble.ALIVE_SECONDS * 1.5)
	assert_bool(_map.is_game_over()).is_true()

func test_맵에_캐릭터가_모두_아웃되면_게임을_종료한다() -> void:
	var character := Character.new(Vector2i(4, 2))
	_map.add_character(character)
	_map.let_character_out(character)
	assert_bool(_map.has_character(Vector2i(4, 2))).is_false()
	assert_bool(_map.is_game_over()).is_true()

# 물줄기 전파
func test_물풍선이_물줄기_위치에_있으면_같이_터진다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	var water_stream := WaterStream.new(Vector2i(4, 2), Vector2i.ZERO)
	_map.add_water_balloon(water_balloon)
	_map.add_water_stream(water_stream)
	_map.tick(WaterStream.DURATION * 0.1)
	assert_bool(_map.has_water_balloon(Vector2i(4, 2))).is_false()

func test_물줄기에_맞아_같이_터진_물풍선에도_물줄기가_생긴다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(water_balloon)
	_map.add_water_streams(Vector2i(5, 2))
	_map.tick(WaterStream.DURATION * 0.1)
	assert_array(_map.water_stream_positions()).contains(
		[Vector2i(4, 2), Vector2i(4, 1), Vector2i(4, 3), Vector2i(3, 2), Vector2i(5, 2)
		,Vector2i(5, 1), Vector2i(5, 3), Vector2i(6, 2)])

func test_물풍선_하나가_터지면_물줄기_위치에_있는_물풍선도_같이_터진다() -> void:
	var water_balloon1 := WaterBalloon.new(Vector2i(4, 2))
	_map.add_water_balloon(water_balloon1)
	_map.tick(WaterBalloon.POP_AFTER_SECONDS * 0.5)
	var water_balloon2 := WaterBalloon.new(Vector2i(5, 2))
	_map.add_water_balloon(water_balloon2)
	_map.tick(WaterBalloon.POP_AFTER_SECONDS * 0.5)
	assert_array(_map.water_stream_positions()).contains(
		[Vector2i(4, 2), Vector2i(4, 1), Vector2i(4, 3), Vector2i(3, 2), Vector2i(5, 2)
		,Vector2i(5, 1), Vector2i(5, 3), Vector2i(6, 2)])

# 게임 아이템
func test_맵의_특정_위치에_게임_아이템을_배치할_수_있다() -> void:
	assert_bool(_map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(3, 2))).is_true()

func test_게임_아이템은_맵의_중복된_위치에_배치할_수_없다() -> void:
	assert_bool(_map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(3, 2))).is_true()
	assert_bool(_map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(3, 2))).is_false()

func test_게임_아이템은_물줄기를_맞으면_제거된다() -> void:
	_map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(5, 2))
	assert_bool(_map.has_game_item(Vector2i(5, 2))).is_true()
	_map.add_water_streams(Vector2i(6, 2))
	_map.tick(0.1)
	assert_bool(_map.has_game_item(Vector2i(5, 2))).is_false()

func test_캐릭터가_게임_아이템_위치로_이동하면_아이템이_먹혀_맵에서_사라진다() -> void:
	var character := Character.new(Vector2i(4, 7))
	_map.add_character(character)
	_map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(4, 8))
	assert_bool(_map.has_game_item(Vector2i(4, 8))).is_true()
	character.move(Vector2i.DOWN, 0.25, _map.water_balloon_positions())
	_map.tick(0.25)
	assert_bool(_map.has_game_item(Vector2i(4, 8))).is_false()

func test_물방울에_갇힌_캐릭터가_게임_아이템_위치로_이동하면_아이템이_사라지지_않는다() -> void:
	var character := Character.new(Vector2i(4, 7))
	_map.add_character(character)
	_map.add_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT, Vector2i(4, 8))
	assert_bool(_map.has_game_item(Vector2i(4, 8))).is_true()
	character.trapped()
	character.move(Vector2i.DOWN, 0.25, _map.water_balloon_positions())
	_map.tick(0.25)
	assert_bool(_map.has_game_item(Vector2i(4, 8))).is_true()