extends GdUnitTestSuite

func test_그리드를_픽셀로_변환한다() -> void:
	var grid := Vector2i(2, 3)
	assert_vector(Map.to_pixel(grid)).is_equal(Vector2(128, 192))

func test_그리드가_원점이면_픽셀도_원점을_반환한다() -> void:
	var grid := Vector2i.ZERO
	assert_vector(Map.to_pixel(grid)).is_equal(Vector2.ZERO)
