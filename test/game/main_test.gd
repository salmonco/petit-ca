extends GdUnitTestSuite

const SCENE_PATH := "res://scenes/main.tscn"

var _runner: GdUnitSceneRunner
var _main: Main

func before_test() -> void:
	_runner = scene_runner(SCENE_PATH)
	_main = _runner.scene()

func test_시작_시_캐릭터가_맵의_시작_칸에_위치한다() -> void:
	var start_position := _main.character.position
	var start_pixel := Map.to_pixel(start_position)
	assert_vector(_main.character_view.position).is_equal(start_pixel)

func test_키보드_위쪽_방향키를_누르면_캐릭터가_위로_한_칸_이동한다() -> void:
	var initial_position := _main.character_view.position
	_main.handle_key(KEY_UP)
	var expected_position := initial_position + Vector2.UP * Map.PIXELS_PER_CELL
	assert_vector(_main.character_view.position).is_equal(expected_position)
