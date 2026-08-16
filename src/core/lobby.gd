class_name Lobby
extends RefCounted

var rooms: Array[Room] = []

func _init() -> void:
	pass

func add_room(room: Room) -> void:
	rooms.append(room)

func room_count() -> int:
	return rooms.size()

func find_room(id: String) -> Room:
	for room in rooms:
		if room.id == id:
			return room
	return null
