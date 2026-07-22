extends GdUnitTestSuite

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
