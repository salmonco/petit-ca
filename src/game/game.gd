class_name Game
extends Node

@onready var lobby_view: LobbyView = $LobbyView
@onready var room_view: Control = $RoomView

var lobby := Lobby.new()
var current_room: Room

func _ready() -> void:
	lobby_view.enter_button.pressed.connect(enter_typed_room)

func enter_typed_room() -> void:
	enter_room(lobby_view.room_id())

func enter_room(id: String) -> void:
	var room := lobby.find_room(id)
	if room == null:
		return
	current_room = room
	lobby_view.visible = false
	room_view.visible = true
