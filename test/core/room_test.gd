extends GdUnitTestSuite

func test_방에서_게임을_시작하면_방에_있는_캐릭터가_맵에_추가된다() -> void:
	var room := Room.new()
	var character := Character.new(Vector2i(1, 2))
	room.add_character(character)
	room.game_start()
	assert_array(room.get_battle().get_map().characters()).is_equal([character])

func test_방에_들어온_순서대로_자리_번호를_받는다() -> void:
	var room := Room.new()
	var first := Character.new(Vector2i(1, 2), 7, Color.RED)
	var second := Character.new(Vector2i(3, 5), 7, Color.BLUE)
	room.add_character(first)
	room.add_character(second)
	assert_int(first.number).is_equal(1)
	assert_int(second.number).is_equal(2)

func test_가운데_자리가_비면_새로_들어온_캐릭터가_그_자리를_받는다() -> void:
	var room := Room.new()
	var first := Character.new(Vector2i(1, 2))
	var second := Character.new(Vector2i(3, 5))
	var third := Character.new(Vector2i(4, 7))
	room.add_character(first)
	room.add_character(second)
	room.add_character(third)
	room.remove_character(second)
	var joined := Character.new(Vector2i(6, 9))
	room.add_character(joined)
	assert_int(joined.number).is_equal(2)

func test_방에서_캐릭터가_나가면_그_캐릭터만_빠진다() -> void:
	var room := Room.new()
	var leaving := Character.new(Vector2i(1, 2))
	var staying := Character.new(Vector2i(3, 5))
	room.add_character(leaving)
	room.add_character(staying)
	room.remove_character(leaving)
	assert_array(room.characters()).is_equal([staying])

func test_방에서_나간_캐릭터는_방에_속하지_않는다() -> void:
	var room := Room.new()
	var character := Character.new(Vector2i(1, 2))
	room.add_character(character)
	room.remove_character(character)
	assert_str(character.joined_room_id).is_not_equal(room.id)

func test_게임을_시작하면_자리_번호에_맞는_칸에서_시작한다() -> void:
	var room := Room.new()
	var first := Character.new(Vector2i(9, 9))
	var second := Character.new(Vector2i(9, 9))
	room.add_character(first)
	room.add_character(second)
	room.game_start()
	assert_vector(first.position()).is_equal(Vector2i(1, 6))
	assert_vector(second.position()).is_equal(Vector2i(13, 6))

func test_방에서_배틀_모드를_변경할_수_있다() -> void:
	var room := Room.new()
	room.set_battle_mode(BattleMode.MONSTER)
	assert_str(room.battle_mode).is_equal(BattleMode.MONSTER)

func test_게임을_시작하면_설정한_배틀_모드가_배틀에_반영된다() -> void:
	var room := Room.new()
	room.set_battle_mode(BattleMode.MONSTER)
	room.game_start()
	assert_str(room.get_battle().get_mode()).is_equal(BattleMode.MONSTER)

func test_두_팀_이상이어야_게임_시작이_가능하다() -> void:
	var room := Room.new()
	var character1 := Character.new(Vector2i(1, 2), 0, Color.RED)
	var character2 := Character.new(Vector2i(1, 2), 0, Color.RED)
	room.add_character(character1)
	room.add_character(character2)
	assert_int(room.team_count()).is_equal(1)
	assert_bool(room.can_game_start()).is_false()
	var character3 := Character.new(Vector2i(1, 2), 0, Color.BLUE)
	room.add_character(character3)
	assert_int(room.team_count()).is_equal(2)
	assert_bool(room.can_game_start()).is_true()

func test_몬스터_모드로_바꾸면_NPC가_다른_팀이_되어_게임을_시작할_수_있다() -> void:
	var room := Room.new()
	room.add_character(Character.new(Vector2i(1, 2), 1, Color.RED))
	assert_int(room.team_count()).is_equal(1)
	room.set_battle_mode(BattleMode.MONSTER)
	assert_int(room.team_count()).is_equal(2)
	assert_bool(room.can_game_start()).is_true()

func test_몬스터_모드면_방에_NPC가_들어와_있는다() -> void:
	var room := Room.new()
	assert_bool(room.has_npc()).is_false()
	room.set_battle_mode(BattleMode.MONSTER)
	assert_bool(room.has_npc()).is_true()