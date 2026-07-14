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

func test_키보드_스페이스_바를_누르면_캐릭터가_물풍선을_놓는다() -> void:
	_main.handle_key(KEY_SPACE)
	var views := _main.water_balloon_views.get_children()
	assert_vector((views[0] as ColorRect).position).is_equal(Map.to_pixel(_main.character.position))
	
func test_서로_다른_두_칸에_물풍선을_놓으면_물풍선이_두_개_그려진다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.handle_key(KEY_RIGHT)
	_main.handle_key(KEY_SPACE)
	assert_int(_main.water_balloon_views.get_child_count()).is_equal(2)
