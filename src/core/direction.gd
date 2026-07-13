class_name Direction

const _DIRECTION := {
	KEY_UP: Vector2i.UP,
	KEY_DOWN: Vector2i.DOWN,
	KEY_LEFT: Vector2i.LEFT,
	KEY_RIGHT: Vector2i.RIGHT	
}

static func from_key(key: Key) -> Vector2i:
	return _DIRECTION[key]
