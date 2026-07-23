extends GdUnitTestSuite

var _map: Map
var _battle: Battle

func before_test() -> void:
	_map = Map.new()
	_battle = Battle.new(_map)

# 게임 오버
func test_맵에_인간_캐릭터가_아웃되면_게임을_종료한다() -> void:
	var npc := Npc.new(Vector2i(9, 10))
	var human := Character.new(Vector2i(4, 2))
	_map.add_character(npc)
	_map.add_character(human)
	assert_bool(_battle.is_game_over()).is_false()
	_map.let_character_out(human)
	assert_bool(_battle.is_game_over()).is_true()

func test_맵에_NPC가_아웃되면_게임을_종료한다() -> void:
	var npc := Npc.new(Vector2i(9, 10))
	var human := Character.new(Vector2i(4, 2))
	_map.add_character(npc)
	_map.add_character(human)
	assert_bool(_battle.is_game_over()).is_false()
	_map.let_character_out(npc)
	assert_bool(_battle.is_game_over()).is_true()

# 승패
func test_맵에_인간_캐릭터가_모두_아웃되면_게임에서_진다() -> void:
	var npc := Npc.new(Vector2i(9, 10))
	var human := Character.new(Vector2i(4, 2))
	_map.add_character(npc)
	_map.add_character(human)
	assert_bool(_battle.is_lose()).is_false()
	_map.let_character_out(human)
	assert_bool(_battle.is_lose()).is_true()

func test_맵에_NPC가_모두_아웃되면_게임에서_이긴다() -> void:
	var npc := Npc.new(Vector2i(9, 10))
	var human := Character.new(Vector2i(4, 2))
	_map.add_character(npc)
	_map.add_character(human)
	assert_bool(_battle.is_win()).is_false()
	_map.let_character_out(npc)
	assert_bool(_battle.is_win()).is_true()

func test_맵에_인간_캐릭터와_NPC_모두_아웃되면_무승부가_된다() -> void:
	var npc := Npc.new(Vector2i(9, 10))
	var human := Character.new(Vector2i(4, 2))
	_map.add_character(npc)
	_map.add_character(human)
	assert_bool(_battle.is_draw()).is_false()
	_map.let_character_out(npc)
	_map.let_character_out(human)
	assert_bool(_battle.is_draw()).is_true()