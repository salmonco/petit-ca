class_name Game
extends Node

@onready var lobby_view: LobbyView = $LobbyView
@onready var room_view: RoomView = $RoomView

var lobby := Lobby.new()
var current_room: Room

func _ready() -> void:
	lobby_view.create_room_button.pressed.connect(create_room)

func create_room() -> void:
	enter_room(lobby.create_room().id)

func enter_room(id: String) -> void:
	var room := lobby.find_room(id)
	if room == null:
		return
	current_room = room
	room_view.render(room)
	lobby_view.visible = false
	room_view.visible = true
