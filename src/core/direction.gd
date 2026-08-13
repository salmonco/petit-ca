class_name Direction
extends RefCounted

const _DIRECTION: Dictionary[Key, Vector2i] = {
	KEY_UP: Vector2i.UP,
	KEY_DOWN: Vector2i.DOWN,
	KEY_LEFT: Vector2i.LEFT,
	KEY_RIGHT: Vector2i.RIGHT
}

const _LOCAL_MULTI_DIRECTION: Dictionary[Key, Vector2i] = {
	KEY_R: Vector2i.UP,
	KEY_F: Vector2i.DOWN,
	KEY_D: Vector2i.LEFT,
	KEY_G: Vector2i.RIGHT
}

static func from_key(key: Key) -> Vector2i:
	return _DIRECTION.get(key, Vector2i.ZERO)

static func has(key: Key) -> bool:
	return _DIRECTION.has(key)
 
static func from_key_local_multi(key: Key) -> Vector2i:
	return _LOCAL_MULTI_DIRECTION.get(key, Vector2i.ZERO)

static func has_local_multi(key: Key) -> bool:
	return _LOCAL_MULTI_DIRECTION.has(key)
