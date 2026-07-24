extends GdUnitTestSuite

const SCENE_PATH := "res://scenes/main.tscn"

var _runner: GdUnitSceneRunner
var _main: Main

func before_test() -> void:
	_runner = scene_runner(SCENE_PATH)
	_main = _runner.scene()

# 캐릭터 이동
func test_시작_시_캐릭터가_맵의_시작_칸에_위치한다() -> void:
	var view: CharacterView = _main.view_by_character[_main.player]
	assert_vector(view.position).is_equal(_main.player.pixel_position())

func test_캐릭터가_이동하면_뷰가_새_칸을_따라온다() -> void:
	var start_cell := _main.player.position()
	_main.player.move(Vector2i.RIGHT, 0.25, [])
	_main.tick(0.25)
	var moved_cell := _main.player.position()
	assert_vector(moved_cell).is_not_equal(start_cell)
	var view: CharacterView = _main.view_by_character[_main.player]
	assert_vector(view.position).is_equal(Map.to_pixel(moved_cell))

# 물풍선 놓기
func test_키보드_스페이스_바를_누르면_캐릭터가_물풍선을_놓는다() -> void:
	_main.handle_key(KEY_SPACE)
	var views := _main.water_balloon_views.get_children()
	assert_vector((views[0] as Sprite2D).position).is_equal(_main.player.pixel_position())

func test_서로_다른_두_칸에_물풍선을_놓으면_물풍선이_두_개_그려진다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.player.move(Vector2i.RIGHT, 0.25, [])
	_main.player.get_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT)
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

func test_물줄기_방향에_맞는_텍스쳐가_보인다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	var cells := {}
	for view: Sprite2D in _main.water_stream_views.get_children():
		cells[view.position] = view.texture
	var center_cell := _main.player.position()
	assert_that(cells[Map.to_pixel_center(center_cell)]).is_equal(_main.WATER_STREAM_TEXTURES["center"])
	assert_that(cells[Map.to_pixel_center(center_cell + Vector2i.UP)]).is_equal(_main.WATER_STREAM_TEXTURES["end"])
	assert_that(cells[Map.to_pixel_center(center_cell + Vector2i.DOWN)]).is_equal(_main.WATER_STREAM_TEXTURES["end"])
	assert_that(cells[Map.to_pixel_center(center_cell + Vector2i.LEFT)]).is_equal(_main.WATER_STREAM_TEXTURES["end"])
	assert_that(cells[Map.to_pixel_center(center_cell + Vector2i.RIGHT)]).is_equal(_main.WATER_STREAM_TEXTURES["end"])

# 물방울에 갇힘
func test_캐릭터는_물줄기를_맞으면_물방울에_갇혀_보인다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	var view: CharacterView = _main.view_by_character[_main.player]
	assert_str(view.animation).is_equal("bubble")

# 자동 아웃
func test_캐릭터가_물방울에_갇힌_후_일정_시간이_지나면_화면에서_사라진다() -> void:
	var original_count = _main.character_views.get_child_count()
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	_main.tick(WaterStream.DURATION * 0.5)
	_main.tick(Bubble.ALIVE_SECONDS * 5.0)
	assert_int(_main.character_views.get_child_count()).is_equal(original_count - 1)

# 게임 오버
func test_게임에서_지면_졌다는_텍스트가_표시된다() -> void:
	_main.handle_key(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	_main.tick(WaterStream.DURATION * 0.5)
	assert_bool(_main.lose_label.visible).is_false()
	_main.tick(Bubble.ALIVE_SECONDS * 5.0)
	assert_bool(_main.lose_label.visible).is_true()

# 게임 아이템
func test_게임_시작_시_맵의_특정_위치에_게임_아이템이_표시된다() -> void:
	assert_that((_main.game_item_views.get_child(0) as Sprite2D).texture).is_equal(_main.GAME_ITEM_WATER_BALLOON_TEXTURE)

# 물풍선 비주얼
func test_NPC가_놓은_물풍선은_플레이어의_것과_다른_텍스처로_보인다() -> void:
	_main.handle_key(KEY_SPACE)
	var npc_cell := _main.npc.position()
	var player_cell := _main.player.position()
	_main.npc.place_water_balloon(_main.map)
	_main.tick(0.1)
	var textures := {}
	for view: Sprite2D in _main.water_balloon_views.get_children():
		textures[view.position] = view.texture
	assert_that(textures[Map.to_pixel(player_cell)]).is_equal(_main.PLAYER_WATER_BALLOON_TEXTURE)
	assert_that(textures[Map.to_pixel(npc_cell)]).is_equal(_main.NPC_WATER_BALLOON_TEXTURE)