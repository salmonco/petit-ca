extends GdUnitTestSuite

var _map: Map

func before_test() -> void:
	_map = Map.new()

func test_물줄기는_시간이_다_지나면_사라진다() -> void:
	var water_stream := WaterStream.new(Vector2i(5, 4), Vector2i.ZERO)
	var is_removed := water_stream.tick(WaterStream.DURATION * 1.5)
	assert_bool(is_removed).is_true()

func test_물줄기는_시간이_다_지나지_않으면_사라지지_않는다() -> void:
	var water_stream := WaterStream.new(Vector2i(5, 4), Vector2i.ZERO)
	var is_removed := water_stream.tick(WaterStream.DURATION * 0.5)
	assert_bool(is_removed).is_false()