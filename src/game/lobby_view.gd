class_name LobbyView
extends Control

# UUID 전체는 화면에 길어서 앞자리만 보여준다. 사람이 입력하는 값이 아니라 알아보기용이다.
const ROOM_ID_DIGITS := 8

@onready var room_list: VBoxContainer = $CenterContainer/VBoxContainer/RoomList
@onready var create_room_button: Button = $CenterContainer/VBoxContainer/CreateRoomButton

func render(lobby: Lobby) -> void:
	_clear_room_list()
	for room in lobby.rooms:
		room_list.add_child(_create_room_entry(room))

func room_count() -> int:
	return room_list.get_child_count()

func _clear_room_list() -> void:
	for entry in room_list.get_children():
		room_list.remove_child(entry)
		entry.queue_free()

func _create_room_entry(room: Room) -> Button:
	var entry := Button.new()
	entry.text = "방 %s" % room.id.substr(0, ROOM_ID_DIGITS)
	return entry
