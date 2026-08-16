extends GdUnitTestSuite

func test_로비에서_방을_추가할_수_있다() -> void:
	var lobby := Lobby.new()
	var room := Room.new()
	lobby.add_room(room)
	assert_int(lobby.room_count()).is_equal(1)

func test_방_목록을_알_수_있다() -> void:
	var lobby := Lobby.new()
	var room1 := Room.new()
	var room2 := Room.new()
	lobby.add_room(room1)
	lobby.add_room(room2)
	assert_array(lobby.rooms).is_equal([room1, room2])

func test_ID로_방을_찾는다() -> void:
	var lobby := Lobby.new()
	var room1 := Room.new()
	var room2 := Room.new()
	lobby.add_room(room1)
	lobby.add_room(room2)
	assert_that(lobby.find_room(room2.id)).is_equal(room2)
