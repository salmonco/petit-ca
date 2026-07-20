extends GdUnitTestSuite

const SCENE_PATH := "res://scenes/main.tscn"

var _runner: GdUnitSceneRunner
var _main: Main

func before_test() -> void:
	_runner = scene_runner(SCENE_PATH)
	_main = _runner.scene()

# 캐릭터 이동
func test_시작_시_캐릭터가_맵의_시작_칸에_위치한다() -> void:
	var start_position := _main.map.character_positions()[0]
	var start_pixel := Map.to_pixel(start_position)
	assert_vector(_main.character_views.get_child(0).position).is_equal(start_pixel)

func test_캐릭터가_이동하면_격자를_걸쳐서_보인다() -> void:
	_main.map.characters()[0].move(Vector2i.RIGHT, 0.1, [])
	_main.tick(0.1)
	assert_vector(_main.character_views.get_child(0).position).is_equal(_main.map.characters()[0].pixel_position())

# 물풍선 놓기
func test_키보드_스페이스_바를_누르면_캐릭터가_물풍선을_놓는다() -> void:
	_main.handle_key(KEY_SPACE)
	var views := _main.water_balloon_views.get_children()
	assert_vector((views[0] as Sprite2D).position).is_equal(Map.to_pixel(_main.map.character_positions()[0]))

func test_서로_다른_두_칸에_물풍선을_놓으면_물풍선이_두_개_그려진다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.map.characters()[0].move(Vector2i.RIGHT, 0.25, [])
	_main.handle_key(KEY_SPACE)
	assert_int(_main.water_balloon_views.get_child_count()).is_equal(2)

# 물풍선 터지기
func test_시간이_다_지나면_물풍선이_화면에서_사라진다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS * 1.5)
	assert_int(_main.water_balloon_views.get_child_count()).is_equal(0)

func test_시간이_다_지나지_않으면_물풍선이_화면에서_사라지지_않는다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS * 0.5)
	assert_int(_main.water_balloon_views.get_child_count()).is_equal(1)

# 물줄기 보이기
func test_물풍선_하나가_터질_때_물줄기가_5칸_보인다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_int(_main.water_stream_views.get_child_count()).is_equal(5)

# 물방울에 갇힘
func test_캐릭터는_물줄기를_맞으면_물방울에_갇혀_보인다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_that((_main.character_views.get_child(0) as ColorRect).color).is_equal(_main.BUBBLE_COLOR)

# 자동 아웃
func test_캐릭터가_물방울에_갇힌_후_일정_시간이_지나면_화면에서_사라진다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	_main.tick(WaterStream.DURATION * 0.5)
	_main.tick(Bubble.ALIVE_SECONDS * 5.0)
	assert_int(_main.character_views.get_child_count()).is_equal(0)

# 게임 오버
func test_게임이_종료되면_게임_오버_텍스트가_표시된다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	_main.tick(WaterStream.DURATION * 0.5)
	assert_bool(_main.game_over_label.visible).is_false()
	_main.tick(Bubble.ALIVE_SECONDS * 5.0)
	assert_bool(_main.game_over_label.visible).is_true()