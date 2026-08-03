extends GdUnitTestSuite

var _battle: Battle
var _human: Character
var _npc: Npc

func before_test() -> void:
	var map := Map.new()
	_battle = Battle.new(map, BattleMode.MONSTER)
	_human = Character.new(Vector2i(4, 2))
	_npc = Npc.new(Vector2i(9, 10))
	map.add_character(_human)
	map.add_character(_npc)

# 게임 오버
func test_맵에_인간_캐릭터가_아웃되면_게임을_종료한다() -> void:
	assert_bool(_battle.is_game_over()).is_false()
	_battle.get_map().let_character_out(_human)
	_battle.tick(0.1)
	assert_bool(_battle.is_game_over()).is_true()

func test_맵에_NPC가_아웃되면_게임을_종료한다() -> void:
	assert_bool(_battle.is_game_over()).is_false()
	_battle.get_map().let_character_out(_npc)
	_battle.tick(0.1)
	assert_bool(_battle.is_game_over()).is_true()

func test_하나의_배틀에서_승패가_난_후에_또_다시_승패가_나지_않는다() -> void:
	assert_bool(_battle.is_game_over()).is_false()
	assert_str(_battle.result_type).is_not_equal("lose")
	_battle.get_map().let_character_out(_human)
	_battle.tick(0.1)
	assert_bool(_battle.is_game_over()).is_true()
	assert_str(_battle.result_type).is_equal("lose")
	_battle.get_map().let_character_out(_npc)
	_battle.tick(0.1)
	assert_bool(_battle.is_game_over()).is_true()
	assert_str(_battle.result_type).is_equal("lose")

# 승패
func test_맵에_인간_캐릭터가_모두_아웃되면_게임에서_진다() -> void:
	assert_str(_battle.result_type).is_not_equal("lose")
	_battle.get_map().let_character_out(_human)
	_battle.tick(0.1)
	assert_str(_battle.result_type).is_equal("lose")

func test_맵에_NPC가_모두_아웃되면_게임에서_이긴다() -> void:
	assert_str(_battle.result_type).is_not_equal("win")
	_battle.get_map().let_character_out(_npc)
	_battle.tick(0.1)
	assert_str(_battle.result_type).is_equal("win")

func test_맵에_인간_캐릭터와_NPC_모두_아웃되면_무승부가_된다() -> void:
	assert_str(_battle.result_type).is_not_equal("draw")
	_battle.get_map().let_character_out(_npc)
	_battle.get_map().let_character_out(_human)
	_battle.tick(0.1)
	assert_str(_battle.result_type).is_equal("draw")