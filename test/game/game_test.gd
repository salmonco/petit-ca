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

func test_방의_나가기_버튼이_나가기에_연결되어_있다() -> void:
	assert_bool(_game.room_view.leave_button.pressed.is_connected(_game.leave_room)).is_true()

func test_로비의_방_만들기_버튼이_방_만들기에_연결되어_있다() -> void:
	assert_bool(_game.lobby_view.create_room_button.pressed.is_connected(_game.create_room)).is_true()

func test_방에_들어가면_캐릭터_수만큼_슬롯이_생긴다() -> void:
	var room := _room_with_characters(3)
	_game.enter_room(room.id)
	assert_int(_game.room_view.slot_count()).is_equal(3)

func test_다른_방에_들어가면_이전_방의_슬롯이_남지_않는다() -> void:
	var crowded_room := _room_with_characters(3)
	var quiet_room := _room_with_characters(1)
	_game.enter_room(crowded_room.id)
	_game.enter_room(quiet_room.id)
	assert_int(_game.room_view.slot_count()).is_equal(1)

func _room_with_characters(count: int) -> Room:
	var room := Room.new()
	for i in count:
		room.add_character(Character.new(Vector2i(i + 1, i + 3), i + 1, Color.RED))
	_game.lobby.add_room(room)
	return room
