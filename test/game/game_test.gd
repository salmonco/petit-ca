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

func test_로비에_입력한_방_ID로_입장한다() -> void:
	var room := Room.new()
	_game.lobby.add_room(room)
	_game.lobby_view.room_id_input.text = room.id
	_game.enter_typed_room()
	assert_that(_game.current_room).is_equal(room)
	assert_bool(_game.room_view.visible).is_true()

func test_로비에_없는_방_ID를_입력하면_입장하지_못한다() -> void:
	var room := Room.new()
	_game.lobby.add_room(room)
	_game.lobby_view.room_id_input.text = "없는-방-id"
	_game.enter_typed_room()
	assert_that(_game.current_room).is_null()
	assert_bool(_game.room_view.visible).is_false()

func test_로비의_입장_버튼이_입장에_연결되어_있다() -> void:
	assert_bool(_game.lobby_view.enter_button.pressed.is_connected(_game.enter_typed_room)).is_true()
