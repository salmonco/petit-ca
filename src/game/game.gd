class_name Game
extends Node

@onready var lobby_view: Control = $LobbyView
@onready var room_view: Control = $RoomView

var lobby := Lobby.new()
var current_room: Room

func enter_room(id: String) -> void:
	var room := lobby.find_room(id)
	if room == null:
		return
	current_room = room
	lobby_view.visible = false
	room_view.visible = true
