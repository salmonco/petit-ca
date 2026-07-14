extends GdUnitTestSuite

func test_그리드를_픽셀로_변환한다() -> void:
	var grid := Vector2i(2, 3)
	assert_vector(Map.to_pixel(grid)).is_equal(Vector2(128, 192))

func test_그리드가_원점이면_픽셀도_원점을_반환한다() -> void:
	var grid := Vector2i.ZERO
	assert_vector(Map.to_pixel(grid)).is_equal(Vector2.ZERO)

# 물풍선 터지기
func test_시간이_다_지나면_터진_물풍선을_반환한다() -> void:
	var map := Map.new()
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	map.add_water_balloon(water_balloon)
	var popped_water_balloons := map.tick(4.0)
	assert_array(popped_water_balloons).contains_exactly([water_balloon])

func test_터진_물풍선은_맵에서_사라진다() -> void:
	var map := Map.new()
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	map.add_water_balloon(water_balloon)
	map.tick(4.0)
	assert_int(map.water_balloon_count()).is_equal(0)

func test_물풍선_중에_안_터진_물풍선은_맵에_남아있다() -> void:
	var map := Map.new()
	var old_balloon := WaterBalloon.new(Vector2i(4, 2))
	map.add_water_balloon(old_balloon)
	map.tick(2.0)
	var new_balloon := WaterBalloon.new(Vector2i(5, 7))
	map.add_water_balloon(new_balloon)
	map.tick(2.0)
	assert_bool(map.has_water_balloon(Vector2i(4, 2))).is_false()
	assert_bool(map.has_water_balloon(Vector2i(5, 7))).is_true()

func test_같은_칸에_물풍선을_다시_놓아도_먼저_놓인_물풍선의_시간은_리셋되지_않는다() -> void:
	var map := Map.new()
	var old_balloon := WaterBalloon.new(Vector2i(4, 2))
	map.add_water_balloon(old_balloon)
	map.tick(2.0)
	var new_balloon := WaterBalloon.new(Vector2i(4, 2))
	map.add_water_balloon(new_balloon)
	map.tick(2.0)
	assert_bool(map.has_water_balloon(Vector2i(4, 2))).is_false()
