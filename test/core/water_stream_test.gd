extends GdUnitTestSuite

func test_물풍선이_터지면_물줄기가_생긴다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	water_balloon.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_bool(water_balloon.has_water_stream()).is_true()

func test_물풍선이_터질_때만_물줄기가_생긴다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	water_balloon.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_bool(water_balloon.has_water_stream()).is_true()
	water_balloon.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_bool(water_balloon.has_water_stream()).is_false()

func test_물풍선이_터지면_물줄기가_상하좌우로_한_칸씩_생긴다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(4, 2))
	water_balloon.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_array(water_balloon.water_stream_positions()).contains_exactly([Vector2i(4, 1), Vector2i(4, 3), Vector2i(3, 2), Vector2i(5, 2)])
