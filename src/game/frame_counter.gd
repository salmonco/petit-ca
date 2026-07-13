# Node 레이어 예시 — 엔진(_process 콜백)에 의존하는 코드는 이렇게 얇게 유지하고,
# 실제 규칙 계산은 src/core/ 의 순수 객체(TickClock 등)에 위임합니다.
# 이 파일 자체는 GdUnit4의 scene_runner로 프레임을 시뮬레이션해 테스트합니다.
class_name FrameCounter
extends Node

signal ticked(total_ticks: int)

@export var tick_seconds: float = 0.1

var frames: int = 0
var _clock: TickClock


func _ready() -> void:
	_clock = TickClock.new(tick_seconds)


func _process(delta: float) -> void:
	frames += 1
	var new_ticks := _clock.advance(delta)
	if new_ticks > 0:
		ticked.emit(_clock.total_ticks)


func total_ticks() -> int:
	return _clock.total_ticks if _clock != null else 0
