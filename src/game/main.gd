class_name Main
extends Node2D

var character: Character = Character.new(Vector2i(10, 6))
@onready var character_view: ColorRect = $CharacterView

func _ready() -> void:
	character_view.size = Vector2.ONE * Map.CELL_SIZE
	character_view.position = Map.to_pixel(character.position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var keycode := (event as InputEventKey).keycode
		handle_key(keycode)

func handle_key(key: Key) -> void:
	var direction := Direction.from_key(key)
	character.move(direction)
	character_view.position = Map.to_pixel(character.position)
