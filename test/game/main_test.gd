extends GdUnitTestSuite

const SCENE_PATH := "res://scenes/main.tscn"

func test_시작_시_캐릭터가_맵의_시작_칸에_위치한다() -> void:
	var runner := scene_runner(SCENE_PATH)
	var main: Main = runner.scene()

	var start_position := main.character.position
	var start_pixel := Map.to_pixel(start_position)

	assert_vector(main.character_view.position).is_equal(start_pixel)
