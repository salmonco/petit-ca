extends GdUnitTestSuite

# 이동
func test_NPC보다_인간_캐릭터가_위쪽에_있으면_위쪽으로_이동한다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(6, 5))
	var character := Character.new(Vector2i(6, 1))
	map.add_character(npc)
	map.add_character(character)
	assert_vector(npc.decide_move_direction(map)).is_equal(Vector2i.UP)

func test_NPC보다_인간_캐릭터가_아래쪽에_있으면_아래쪽으로_이동한다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(6, 5))
	var character := Character.new(Vector2i(6, 8))
	map.add_character(npc)
	map.add_character(character)
	assert_vector(npc.decide_move_direction(map)).is_equal(Vector2i.DOWN)

func test_NPC보다_인간_캐릭터가_왼쪽에_있으면_왼쪽으로_이동한다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(6, 5))
	var character := Character.new(Vector2i(2, 5))
	map.add_character(npc)
	map.add_character(character)
	assert_vector(npc.decide_move_direction(map)).is_equal(Vector2i.LEFT)

func test_NPC보다_인간_캐릭터가_오른쪽에_있으면_오른쪽으로_이동한다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(6, 5))
	var character := Character.new(Vector2i(8, 5))
	map.add_character(npc)
	map.add_character(character)
	assert_vector(npc.decide_move_direction(map)).is_equal(Vector2i.RIGHT)

func test_인간_캐릭터가_없으면_NPC는_이동하지_않는다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(6, 5))
	map.add_character(npc)
	assert_vector(npc.decide_move_direction(map)).is_equal(Vector2i.ZERO)

# 물풍선 놓기
func test_NPC가_인간_캐릭터로부터_바로_위_칸에_있으면_물풍선을_놓는다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(6, 5))
	var character := Character.new(Vector2i(6, 7))
	map.add_character(npc)
	map.add_character(character)
	assert_bool(npc.should_place_water_balloon(map)).is_false()
	npc.move(Vector2i.DOWN, 0.25, map.water_balloon_positions())
	assert_bool(npc.should_place_water_balloon(map)).is_true()

func test_NPC가_인간_캐릭터로부터_바로_아래_칸에_있으면_물풍선을_놓는다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(6, 9))
	var character := Character.new(Vector2i(6, 7))
	map.add_character(npc)
	map.add_character(character)
	assert_bool(npc.should_place_water_balloon(map)).is_false()
	npc.move(Vector2i.UP, 0.25, map.water_balloon_positions())
	assert_bool(npc.should_place_water_balloon(map)).is_true()

func test_NPC가_인간_캐릭터로부터_바로_왼쪽_칸에_있으면_물풍선을_놓는다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(4, 7))
	var character := Character.new(Vector2i(6, 7))
	map.add_character(npc)
	map.add_character(character)
	assert_bool(npc.should_place_water_balloon(map)).is_false()
	npc.move(Vector2i.RIGHT, 0.25, map.water_balloon_positions())
	assert_bool(npc.should_place_water_balloon(map)).is_true()

func test_NPC가_인간_캐릭터로부터_바로_오른쪽_칸에_있으면_물풍선을_놓는다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(8, 7))
	var character := Character.new(Vector2i(6, 7))
	map.add_character(npc)
	map.add_character(character)
	assert_bool(npc.should_place_water_balloon(map)).is_false()
	npc.move(Vector2i.LEFT, 0.25, map.water_balloon_positions())
	assert_bool(npc.should_place_water_balloon(map)).is_true()

# 놓고 도망
func test_물풍선을_놓은_직후에는_추격_대신_반대_방향으로_후퇴한다() -> void:
	var map := Map.new()
	var npc := Npc.new(Vector2i(3, 5))
	var character := Character.new(Vector2i(3, 8))
	map.add_character(npc)
	map.add_character(character)
	assert_vector(npc.decide_move_direction(map)).is_equal(Vector2i.DOWN)
	npc.place_water_balloon(map)
	assert_vector(npc.decide_move_direction(map)).is_equal(Vector2i.UP)