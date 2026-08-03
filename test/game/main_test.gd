extends GdUnitTestSuite

const SCENE_PATH := "res://scenes/main.tscn"

var _runner: GdUnitSceneRunner
var _main: Main

func before_test() -> void:
	_runner = scene_runner(SCENE_PATH)
	_main = _runner.scene()

# 캐릭터 이동
func test_시작_시_캐릭터가_맵의_시작_칸에_위치한다() -> void:
	var view: CharacterView = _main.view_by_character[_main.second_character]
	assert_vector(view.position).is_equal(_main.second_character.pixel_position())

func test_캐릭터가_이동하면_뷰가_새_칸을_따라온다() -> void:
	var start_cell := _main.second_character.position()
	_main.second_character.move(Vector2i.RIGHT, 0.25, [])
	_main.tick(0.25)
	var moved_cell := _main.second_character.position()
	assert_vector(moved_cell).is_not_equal(start_cell)
	var view: CharacterView = _main.view_by_character[_main.second_character]
	assert_vector(view.position).is_equal(Map.to_pixel(moved_cell))

func test_키보드_방향키_입력을_떼면_캐릭터가_이동하지_않는다() -> void:
	var start_cell := _main.second_character.position()
	var view: CharacterView = _main.view_by_character[_main.second_character]
	_main.handle_key_pressed(KEY_LEFT)
	_main.tick(0.25)
	_main.handle_key_released(KEY_LEFT)
	_main.tick(0.25)
	assert_vector(view.position).is_equal(Map.to_pixel(start_cell + Vector2i.LEFT))

func test_캐릭터는_방향을_바꿔도_연속으로_이동할_수_있다() -> void:
	var start_cell := _main.second_character.position()
	var view: CharacterView = _main.view_by_character[_main.second_character]
	_main.handle_key_pressed(KEY_LEFT)
	_main.tick(0.25)
	_main.handle_key_pressed(KEY_DOWN)
	_main.tick(0.25)
	_main.handle_key_released(KEY_LEFT)
	_main.tick(0.25)
	assert_vector(view.position).is_equal(Map.to_pixel(start_cell + Vector2i.LEFT + Vector2i.DOWN * 2))

# 물풍선 놓기
func test_키보드_스페이스_바를_누르면_캐릭터가_물풍선을_놓는다() -> void:
	_main.start_battle(BattleMode.MONSTER)
	_main.handle_key_pressed(KEY_SPACE)
	_main.tick(0.1)
	var views := _main.water_balloon_views.get_children()
	assert_vector((views[0] as Sprite2D).position).is_equal(_main.second_character.pixel_position())

func test_서로_다른_두_칸에_물풍선을_놓으면_물풍선이_두_개_그려진다() -> void:
	_main.start_battle(BattleMode.MONSTER)
	_main.handle_key_pressed(KEY_SPACE)
	_main.tick(0.1)
	_main.second_character.move(Vector2i.RIGHT, 0.25, [])
	_main.second_character.get_game_item(GameItem.INCREASE_WATER_BALLOON_COUNT)
	_main.handle_key_pressed(KEY_SPACE)
	_main.tick(0.1)
	assert_int(_main.water_balloon_views.get_child_count()).is_equal(2)

# 물풍선 터지기
func test_시간이_다_지나면_물풍선이_화면에서_사라진다() -> void:
	_main.start_battle(BattleMode.MONSTER)
	_main.handle_key_pressed(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS * 1.5)
	assert_int(_main.water_balloon_views.get_child_count()).is_equal(0)

func test_시간이_다_지나지_않으면_물풍선이_화면에서_사라지지_않는다() -> void:
	_main.start_battle(BattleMode.MONSTER)
	_main.handle_key_pressed(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS * 0.5)
	assert_int(_main.water_balloon_views.get_child_count()).is_equal(1)

# 물줄기 보이기
func test_물풍선_하나가_터질_때_물줄기가_5칸_보인다() -> void:
	_main.start_battle(BattleMode.MONSTER)
	_main.handle_key_pressed(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	assert_int(_main.water_stream_views.get_child_count()).is_equal(5)

func test_물줄기_방향에_맞는_텍스쳐가_보인다() -> void:
	_main.start_battle(BattleMode.MONSTER)
	_main.handle_key_pressed(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	var cells := {}
	for view: Sprite2D in _main.water_stream_views.get_children():
		cells[view.position] = view.texture
	var center_cell := _main.second_character.position()
	assert_that(cells[Map.to_pixel_center(center_cell)]).is_equal(_main.WATER_STREAM_TEXTURES["center"])
	assert_that(cells[Map.to_pixel_center(center_cell + Vector2i.UP)]).is_equal(_main.WATER_STREAM_TEXTURES["end"])
	assert_that(cells[Map.to_pixel_center(center_cell + Vector2i.DOWN)]).is_equal(_main.WATER_STREAM_TEXTURES["end"])
	assert_that(cells[Map.to_pixel_center(center_cell + Vector2i.LEFT)]).is_equal(_main.WATER_STREAM_TEXTURES["end"])
	assert_that(cells[Map.to_pixel_center(center_cell + Vector2i.RIGHT)]).is_equal(_main.WATER_STREAM_TEXTURES["end"])

# 물방울에 갇힘
func test_캐릭터는_물줄기를_맞으면_물방울에_갇혀_보인다() -> void:
	_main.start_battle(BattleMode.MONSTER)
	_main.handle_key_pressed(KEY_SPACE)
	_main.tick(WaterBalloon.POP_AFTER_SECONDS)
	var view: CharacterView = _main.view_by_character[_main.second_character]
	assert_str(view.animation).is_equal("bubble")

# 자동 아웃
func test_아웃된_캐릭터는_화면에서_사라진다() -> void:
	var original_count = _main.character_views.get_child_count()
	_main.battle.get_map().let_character_out(_main.second_character)
	_main.tick(0.1)
	assert_int(_main.character_views.get_child_count()).is_equal(original_count - 1)

# 게임 오버
func test_게임에서_지면_졌다는_텍스트가_표시된다() -> void:
	_main.start_battle(BattleMode.MONSTER)
	assert_bool(_main.lose_label.visible).is_false()
	_main.battle.get_map().let_character_out(_main.second_character)
	_main.tick(0.1)
	assert_bool(_main.lose_label.visible).is_true()

# 게임 아이템
func test_게임_시작_시_맵의_특정_위치에_게임_아이템이_표시된다() -> void:
	assert_that((_main.game_item_views.get_child(0) as Sprite2D).texture).is_equal(_main.GAME_ITEM_WATER_BALLOON_TEXTURE)

# 물풍선 비주얼
func test_NPC가_놓은_물풍선은_플레이어의_것과_다른_텍스처로_보인다() -> void:
	_main.start_battle(BattleMode.MONSTER)
	var npc_cell := _main.first_character.position()
	var player_cell := _main.second_character.position()
	_main.first_character.place_water_balloon(_main.battle.get_map())
	_main.handle_key_pressed(KEY_SPACE)
	_main.tick(0.1)
	var textures := {}
	for view: Sprite2D in _main.water_balloon_views.get_children():
		textures[view.position] = view.texture
	assert_that(textures[Map.to_pixel(npc_cell)]).is_equal(_main.NPC_WATER_BALLOON_TEXTURE)
	assert_that(textures[Map.to_pixel(player_cell)]).is_equal(_main.PLAYER_WATER_BALLOON_TEXTURE)

# 로컬 멀티플레이어
func test_키보드_위쪽_방향키를_누르면_2P_플레이어가_위쪽_방향으로_보인다() -> void:
	_main.start_battle(BattleMode.LOCAL_MULTI)
	assert_vector(_main.second_character.facing).is_not_equal(Vector2i.UP)
	_main.handle_key_pressed(KEY_UP)
	_main.tick(0.1)
	assert_vector(_main.second_character.facing).is_equal(Vector2i.UP)

func test_키보드_아래쪽_방향키를_누르면_2P_플레이어가_아래쪽_방향으로_보인다() -> void:
	_main.start_battle(BattleMode.LOCAL_MULTI)
	_main.handle_key_pressed(KEY_DOWN)
	_main.tick(0.1)
	assert_vector(_main.second_character.facing).is_equal(Vector2i.DOWN)

func test_키보드_왼쪽_방향키를_누르면_2P_플레이어가_왼쪽_방향으로_보인다() -> void:
	_main.start_battle(BattleMode.LOCAL_MULTI)
	assert_vector(_main.second_character.facing).is_not_equal(Vector2i.LEFT)
	_main.handle_key_pressed(KEY_LEFT)
	_main.tick(0.1)
	assert_vector(_main.second_character.facing).is_equal(Vector2i.LEFT)

func test_키보드_오른쪽_방향키를_누르면_2P_플레이어가_오른쪽_방향으로_보인다() -> void:
	_main.start_battle(BattleMode.LOCAL_MULTI)
	assert_vector(_main.second_character.facing).is_not_equal(Vector2i.RIGHT)
	_main.handle_key_pressed(KEY_RIGHT)
	_main.tick(0.1)
	assert_vector(_main.second_character.facing).is_equal(Vector2i.RIGHT)

func 키보드_오른쪽_시프트_키를_누르면_2P_플레이어가_물풍선을_놓도록_보인다() -> void:
	return

func 키보드_R_키를_누르면_1P_플레이어가_위쪽_방향으로_보인다() -> void:
	return

func 키보드_F_키를_누르면_1P_플레이어가_아래쪽_방향으로_보인다() -> void:
	return

func 키보드_D_키를_누르면_1P_플레이어가_왼쪽_방향으로_보인다() -> void:
	return

func 키보드_G_키를_누르면_1P_플레이어가_오른쪽_방향으로_보인다() -> void:
	return

func 키보드_왼쪽_시프트_키를_누르면_1P_플레이어가_물풍선을_놓도록_보인다() -> void:
	return