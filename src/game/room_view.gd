class_name RoomView
extends Control

const PLAYER_SLOT_TEXTURE: Texture2D = preload("res://assets/characters/bazzi_down.png")
const NPC_SLOT_TEXTURE: Texture2D = preload("res://assets/npcs/zomkkan_down.png")

@onready var slots: HBoxContainer = $CenterContainer/VBoxContainer/Slots
@onready var monster_mode_check: CheckButton = $CenterContainer/VBoxContainer/MonsterModeCheck
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var leave_button: Button = $CenterContainer/VBoxContainer/LeaveButton

func render(room: Room) -> void:
	_clear_slots()
	for character in room.characters():
		slots.add_child(_create_slot(character))
	start_button.disabled = not room.can_game_start()
	monster_mode_check.set_pressed_no_signal(room.battle_mode == BattleMode.MONSTER)

func slot_count() -> int:
	return slots.get_child_count()

func slot(index: int) -> TextureRect:
	return slots.get_child(index)

func _clear_slots() -> void:
	for slot in slots.get_children():
		slots.remove_child(slot)
		slot.queue_free()

func _create_slot(character: Character) -> TextureRect:
	var slot := TextureRect.new()
	slot.texture = NPC_SLOT_TEXTURE if character is Npc else PLAYER_SLOT_TEXTURE
	slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return slot
