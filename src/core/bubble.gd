class_name Bubble
extends RefCounted

const ALIVE_SECONDS := 5.0

var _elapsed_time: float

func tick(delta: float) -> bool:
	_elapsed_time += delta
	return _elapsed_time >= ALIVE_SECONDS