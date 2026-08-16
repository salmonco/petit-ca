extends GdUnitTestSuite

const SCENE_PATH := "res://scenes/game.tscn"

var _runner: GdUnitSceneRunner
var _game: Game

func before_test() -> void:
	_runner = scene_runner(SCENE_PATH)
	_game = _runner.scene()

func test_방_ID로_입장하면_방_화면이_된다() -> void:
	var room := Room.new()
	_game.lobby.add_room(room)
	_game.enter_room(room.id)
	assert_bool(_game.room_view.visible).is_true()
	assert_bool(_game.lobby_view.visible).is_false()

func test_없는_방_ID로는_입장하지_못한다() -> void:
	var room := Room.new()
	_game.lobby.add_room(room)
	_game.enter_room("없는-방-id")
	assert_bool(_game.room_view.visible).is_false()
	assert_bool(_game.lobby_view.visible).is_true()

func test_방을_만들면_만든_방에_들어가_있다() -> void:
	_game.create_room()
	assert_that(_game.current_room).is_equal(_game.lobby.rooms[0])
	assert_bool(_game.room_view.visible).is_true()
	assert_bool(_game.lobby_view.visible).is_false()

func test_방에서_나가면_로비_화면이_된다() -> void:
	_game.create_room()
	_game.leave_room()
	assert_that(_game.current_room).is_null()
	assert_bool(_game.lobby_view.visible).is_true()
	assert_bool(_game.room_view.visible).is_false()

func test_방에서_나가도_방은_로비에_남는다() -> void:
	_game.create_room()
	var left_room := _game.current_room
	_game.leave_room()
	_game.enter_room(left_room.id)
	assert_that(_game.current_room).is_equal(left_room)

func test_로비에_방_수만큼_목록이_보인다() -> void:
	_create_room_and_leave()
	_create_room_and_leave()
	_create_room_and_leave()
	assert_int(_game.lobby_view.room_count()).is_equal(3)

func test_로비_목록에서_방을_고르면_그_방에_입장한다() -> void:
	_create_room_and_leave()
	_create_room_and_leave()
	var second_room := _game.lobby.rooms[1]
	_game.lobby_view.room_entry(1).pressed.emit()
	assert_that(_game.current_room).is_equal(second_room)
	assert_bool(_game.room_view.visible).is_true()

func test_로비_목록의_방_항목이_입장에_연결되어_있다() -> void:
	assert_bool(_game.lobby_view.room_chosen.is_connected(_game.enter_room)).is_true()

func test_방의_나가기_버튼이_나가기에_연결되어_있다() -> void:
	assert_bool(_game.room_view.leave_button.pressed.is_connected(_game.leave_room)).is_true()

func test_로비의_방_만들기_버튼이_방_만들기에_연결되어_있다() -> void:
	assert_bool(_game.lobby_view.create_room_button.pressed.is_connected(_game.create_room)).is_true()

func test_방에_들어가면_캐릭터_수만큼_슬롯이_생긴다() -> void:
	var room := _room_with_characters(2)
	_game.enter_room(room.id)
	assert_int(_game.room_view.slot_count()).is_equal(3)

func test_방에_입장하면_내_캐릭터가_슬롯에_보인다() -> void:
	_game.create_room()
	assert_array(_game.current_room.characters()).is_equal([_game.player_character])
	assert_int(_game.room_view.slot_count()).is_equal(1)

func test_방에_있는_채로_다른_방에_들어가면_이전_방에서_빠진다() -> void:
	var first_room := _room_with_characters(0)
	var second_room := _room_with_characters(0)
	_game.enter_room(first_room.id)
	_game.enter_room(second_room.id)
	assert_array(first_room.characters()).is_empty()
	assert_array(second_room.characters()).is_equal([_game.player_character])

func test_방을_나갔다_다시_들어가도_내_캐릭터는_하나다() -> void:
	_game.create_room()
	var room := _game.current_room
	_game.leave_room()
	_game.enter_room(room.id)
	assert_int(_game.room_view.slot_count()).is_equal(1)

func test_몬스터_모드를_켜면_NPC_슬롯이_NPC로_그려진다() -> void:
	_game.create_room()
	_game.set_monster_mode(true)
	assert_object(_game.room_view.slot(0).texture).is_equal(RoomView.PLAYER_SLOT_TEXTURE)
	assert_object(_game.room_view.slot(1).texture).is_equal(RoomView.NPC_SLOT_TEXTURE)

func test_방에서_몬스터_모드를_켜면_NPC가_슬롯에_늘어난다() -> void:
	_game.create_room()
	assert_int(_game.room_view.slot_count()).is_equal(1)
	_game.set_monster_mode(true)
	assert_str(_game.current_room.battle_mode).is_equal(BattleMode.MONSTER)
	assert_int(_game.room_view.slot_count()).is_equal(2)

func test_방에서_몬스터_모드를_끄면_NPC가_슬롯에서_빠진다() -> void:
	_game.create_room()
	_game.set_monster_mode(true)
	_game.set_monster_mode(false)
	assert_str(_game.current_room.battle_mode).is_equal(BattleMode.LOCAL_MULTI)
	assert_int(_game.room_view.slot_count()).is_equal(1)

func test_다른_방에_들어가면_몬스터_모드_체크가_그_방을_따른다() -> void:
	_game.create_room()
	_game.room_view.monster_mode_check.button_pressed = true
	assert_str(_game.current_room.battle_mode).is_equal(BattleMode.MONSTER)
	_game.create_room()
	assert_bool(_game.room_view.monster_mode_check.button_pressed).is_false()

func test_방의_몬스터_모드_체크가_모드_변경에_연결되어_있다() -> void:
	assert_bool(_game.room_view.monster_mode_check.toggled.is_connected(_game.set_monster_mode)).is_true()

func test_방에서_게임을_시작하면_배틀_화면이_된다() -> void:
	_game.create_room()
	_game.set_monster_mode(true)
	_game.start_game()
	assert_that(_game.battle_view.battle).is_equal(_game.current_room.get_battle())
	assert_bool(_game.battle_view.visible).is_true()
	assert_bool(_game.room_view.visible).is_false()

func test_로비_화면에서는_승패_라벨이_보이지_않는다() -> void:
	assert_bool(_game.battle_view.win_label.is_visible_in_tree()).is_false()
	assert_bool(_game.battle_view.lose_label.is_visible_in_tree()).is_false()
	assert_bool(_game.battle_view.draw_label.is_visible_in_tree()).is_false()

func test_방에서_시작한_몬스터_배틀에서_스페이스로_내_캐릭터가_물풍선을_놓는다() -> void:
	_start_monster_battle()
	_game.battle_view.handle_key_pressed(KEY_SPACE)
	var views := _game.battle_view.water_balloon_views.get_children()
	assert_int(views.size()).is_equal(1)
	assert_vector((views[0] as Sprite2D).position).is_equal(_game.player_character.pixel_position())

func test_방에서_시작한_몬스터_배틀에서_방향키로_내_캐릭터가_움직인다() -> void:
	_start_monster_battle()
	var start_cell := _game.player_character.position()
	_game.battle_view.handle_key_pressed(KEY_RIGHT)
	_game.battle_view.tick(0.25)
	assert_vector(_game.player_character.position()).is_equal(start_cell + Vector2i.RIGHT)

func _start_monster_battle() -> void:
	_game.create_room()
	_game.set_monster_mode(true)
	_game.start_game()

func test_방의_시작_버튼이_게임_시작에_연결되어_있다() -> void:
	assert_bool(_game.room_view.start_button.pressed.is_connected(_game.start_game)).is_true()

func test_한_팀뿐이면_시작_버튼이_비활성이다() -> void:
	var room := _room_with_characters(2)
	_game.enter_room(room.id)
	assert_bool(_game.room_view.start_button.disabled).is_true()

func test_두_팀_이상이면_시작_버튼이_활성이다() -> void:
	var room := _room_with_characters(2)
	room.add_character(Character.new(Vector2i(4, 6), 3, Color.BLUE))
	_game.enter_room(room.id)
	assert_bool(_game.room_view.start_button.disabled).is_false()

func test_다른_방에_들어가면_이전_방의_슬롯이_남지_않는다() -> void:
	var crowded_room := _room_with_characters(3)
	var empty_room := _room_with_characters(0)
	_game.enter_room(crowded_room.id)
	_game.enter_room(empty_room.id)
	assert_int(_game.room_view.slot_count()).is_equal(1)

func _create_room_and_leave() -> void:
	_game.create_room()
	_game.leave_room()

func _room_with_characters(count: int) -> Room:
	var room := Room.new()
	for i in count:
		room.add_character(Character.new(Vector2i(i + 1, i + 3), i + 1, Color.RED))
	_game.lobby.add_room(room)
	return room
