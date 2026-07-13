extends GdUnitTestSuite

func test_그리드를_픽셀로_변환한다() -> void:
	var grid := Vector2i(2, 3)
	assert_vector(Map.to_pixel(grid)).is_equal(Vector2i(128, 192))
