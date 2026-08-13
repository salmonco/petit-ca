class_name GameKey
extends RefCounted

enum {
	UP, DOWN, LEFT, RIGHT,
	R, F, D, G,
	SPACE, SHIFT_LEFT, SHIFT_RIGHT
}

static func from_key(key: Key, location: KeyLocation = KEY_LOCATION_UNSPECIFIED) -> int:
	match key:
		KEY_UP:
			return UP
		KEY_DOWN:
			return DOWN
		KEY_LEFT:
			return LEFT
		KEY_RIGHT:
			return RIGHT
		KEY_R:
			return R
		KEY_F:
			return F
		KEY_D:
			return D
		KEY_G:
			return G
		KEY_SPACE:
			return SPACE
		KEY_SHIFT:
			if location == KEY_LOCATION_LEFT:
				return SHIFT_LEFT
			if location == KEY_LOCATION_RIGHT:
				return SHIFT_RIGHT
	return -1
