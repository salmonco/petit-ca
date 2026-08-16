class_name Game
extends Node

@onready var lobby_view: LobbyView = $LobbyView
@onready var room_view: RoomView = $RoomView

const PLAYER_START_CELL := Vector2i(1, 6)
const PLAYER_SEAT_NUMBER := 1

var lobby := Lobby.new()
var current_room: Room
var player_character := Character.new(PLAYER_START_CELL, PLAYER_SEAT_NUMBER, Color.RED)

func _ready() -> void:
	lobby_view.create_room_button.pressed.connect(create_room)
	room_view.leave_button.pressed.connect(leave_room)
	lobby_view.room_chosen.connect(enter_room)

func create_room() -> void:
	enter_room(lobby.create_room().id)

func leave_room() -> void:
	current_room.remove_character(player_character)
	current_room = null
	lobby_view.render(lobby)
	room_view.visible = false
	lobby_view.visible = true

func enter_room(id: String) -> void:
	var room := lobby.find_room(id)
	if room == null:
		return
	current_room = room
	room.add_character(player_character)
	room_view.render(room)
	lobby_view.visible = false
	room_view.visible = true
