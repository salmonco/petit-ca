extends GdUnitTestSuite

func test_방에서_게임을_시작하면_방에_있는_캐릭터가_맵에_추가된다() -> void:
	var room := Room.new()
	var character := Character.new(Vector2i(1, 2))
	room.add_character(character)
	room.game_start()
	assert_bool(room.get_battle().get_map().has_character(Vector2i(1, 2))).is_true()

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

func test_몬스터_모드면_방에_NPC가_들어와_있는다() -> void:
	var room := Room.new()
	assert_bool(room.has_npc()).is_false()
	room.set_battle_mode(BattleMode.MONSTER)
	assert_bool(room.has_npc()).is_true()