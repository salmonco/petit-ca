class_name RoomView
extends Control

const PLAYER_SLOT_TEXTURE: Texture2D = preload("res://assets/characters/bazzi_down.png")
const PLAYER_SLOT_MASK: Texture2D = preload("res://assets/characters/bazzi_down_mask.png")
const NPC_SLOT_TEXTURE: Texture2D = preload("res://assets/npcs/zomkkan_down.png")
const NPC_SLOT_MASK: Texture2D = preload("res://assets/npcs/zomkkan_down_mask.png")
const RECOLOR_SHADER: Shader = preload("res://src/game/character_recolor.gdshader")

@onready var slots: HBoxContainer = $CenterContainer/VBoxContainer/Slots
@onready var local_multi_check: CheckButton = $CenterContainer/VBoxContainer/LocalMultiCheck
@onready var monster_mode_check: CheckButton = $CenterContainer/VBoxContainer/MonsterModeCheck
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var leave_button: Button = $CenterContainer/VBoxContainer/LeaveButton

func render(room: Room) -> void:
	_clear_slots()
	for character in room.characters():
		slots.add_child(_create_slot(character))
	start_button.disabled = not room.can_game_start()
	monster_mode_check.set_pressed_no_signal(room.battle_mode == BattleMode.MONSTER)
	local_multi_check.set_pressed_no_signal(_human_count(room) > 1)

func slot_count() -> int:
	return slots.get_child_count()

func slot(index: int) -> TextureRect:
	return slots.get_child(index)

func _human_count(room: Room) -> int:
	var count := 0
	for character in room.characters():
		if character is Npc:
			continue
		count += 1
	return count

func _clear_slots() -> void:
	for slot in slots.get_children():
		slots.remove_child(slot)
		slot.queue_free()

func _create_slot(character: Character) -> TextureRect:
	var is_npc := character is Npc
	var slot := TextureRect.new()
	slot.texture = NPC_SLOT_TEXTURE if is_npc else PLAYER_SLOT_TEXTURE
	slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var recolor := ShaderMaterial.new()
	recolor.shader = RECOLOR_SHADER
	recolor.set_shader_parameter("color", character.color)
	recolor.set_shader_parameter("mask_texture", NPC_SLOT_MASK if is_npc else PLAYER_SLOT_MASK)
	slot.material = recolor
	return slot
