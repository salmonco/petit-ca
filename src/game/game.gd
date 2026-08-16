class_name Game
extends Node

@onready var lobby_view: LobbyView = $LobbyView
@onready var room_view: RoomView = $RoomView
@onready var battle_view: Main = $BattleView

const PLAYER_START_CELL := Vector2i(1, 6)

var lobby := Lobby.new()
var current_room: Room
var player_character := Character.new(PLAYER_START_CELL, 0, Color.RED)

func _ready() -> void:
	lobby_view.create_room_button.pressed.connect(create_room)
	room_view.leave_button.pressed.connect(leave_room)
	lobby_view.room_chosen.connect(enter_room)
	room_view.monster_mode_check.toggled.connect(set_monster_mode)
	room_view.start_button.pressed.connect(start_game)

func create_room() -> void:
	enter_room(lobby.create_room().id)

func start_game() -> void:
	current_room.game_start()
	battle_view.show_battle(current_room.get_battle())
	room_view.visible = false
	battle_view.visible = true

func set_monster_mode(enabled: bool) -> void:
	current_room.set_battle_mode(BattleMode.MONSTER if enabled else BattleMode.LOCAL_MULTI)
	room_view.render(current_room)

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
	if current_room != null:
		leave_room()
	current_room = room
	room.add_character(player_character)
	room_view.render(room)
	lobby_view.visible = false
	room_view.visible = true
