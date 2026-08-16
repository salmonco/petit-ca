class_name RoomView
extends Control

const SLOT_TEXTURE: Texture2D = preload("res://assets/characters/bazzi_down.png")

@onready var slots: HBoxContainer = $CenterContainer/VBoxContainer/Slots
@onready var leave_button: Button = $CenterContainer/VBoxContainer/LeaveButton

func render(room: Room) -> void:
	_clear_slots()
	for _character in room.characters():
		slots.add_child(_create_slot())

func slot_count() -> int:
	return slots.get_child_count()

func _clear_slots() -> void:
	for slot in slots.get_children():
		slots.remove_child(slot)
		slot.queue_free()

func _create_slot() -> TextureRect:
	var slot := TextureRect.new()
	slot.texture = SLOT_TEXTURE
	slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return slot
