extends GdUnitTestSuite

func test_같은_칸에는_언제나_같은_타일이_깔린다() -> void:
	var view: TileView = auto_free(TileView.new())
	assert_object(view.texture_at(Vector2i(3, 5))).is_equal(view.texture_at(Vector2i(3, 5)))
	assert_object(view.texture_at(Vector2i(9, 2))).is_equal(view.texture_at(Vector2i(9, 2)))

func test_맵에_한_가지_타일만_깔리지_않는다() -> void:
	var view: TileView = auto_free(TileView.new())
	var used := {}
	for x in Map.GRID_SIZE.x:
		for y in Map.GRID_SIZE.y:
			used[view.texture_at(Vector2i(x, y))] = true
	assert_int(used.size()).is_greater(1)
