class_name LobbyView
extends Control

@onready var room_id_input: LineEdit = $CenterContainer/VBoxContainer/RoomIdInput
@onready var enter_button: Button = $CenterContainer/VBoxContainer/EnterButton

func room_id() -> String:
	return room_id_input.text
