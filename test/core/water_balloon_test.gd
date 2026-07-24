extends GdUnitTestSuite

var _character: Character

func before() -> void:
	_character = Character.new(Vector2i(5, 8))

func test_물풍선은_놓자마자_터지지_않는다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(3, 5), _character)
	var is_popped := water_balloon.tick(0.1)
	assert_bool(is_popped).is_false()

func test_물풍선은_시간이_다_지나면_터진다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(3, 5), _character)
	var is_popped := water_balloon.tick(5)
	assert_bool(is_popped).is_true()

func test_물풍선은_나눠_흐른_시간을_누적한다() -> void:
	var water_balloon := WaterBalloon.new(Vector2i(3, 5), _character)
	water_balloon.tick(2.0)
	var is_popped := water_balloon.tick(2.0)
	assert_bool(is_popped).is_true()
