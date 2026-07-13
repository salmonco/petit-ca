# 가변 delta를 고정 스텝 "틱"으로 바꾸는 누산기.
#
# RefCounted를 상속합니다 — Node가 아니므로 씬 트리도, 엔진 루프도 필요 없습니다.
# 그래서 테스트에서 그냥 TickClock.new()로 만들고 바로 검증할 수 있고, 밀리초 안에 끝납니다.
# 게임 규칙(폭탄 타이머, 쿨다운, 무적 시간 등)은 이런 순수 객체로 내려두세요.
class_name TickClock
extends RefCounted

## 부동소수점 오차 보정 비율.
## 0.35초를 0.1초 틱으로 나누면 3틱을 소비하고 0.05가 남아야 하지만, 실제 float 연산에서는
## 0.049999999999999996 이 남습니다. 여기에 0.05를 더해도 0.09999999999999999 < 0.1 이라
## 틱이 발생하지 않고, 이 오차가 매 틱 누적되면 폭탄이 영원히 안 터지는 버그가 됩니다.
## 틱 길이에 비례하는 엡실론을 더해 경계값을 흡수합니다.
const EPSILON_RATIO := 1e-6

var total_ticks: int = 0

var _tick_seconds: float
var _accumulated: float = 0.0


func _init(tick_seconds: float = 1.0 / 60.0) -> void:
	assert(tick_seconds > 0.0, "tick_seconds must be positive")
	_tick_seconds = tick_seconds


## delta초만큼 시간을 진행시키고, 이번 호출에서 새로 발생한 틱 수를 반환합니다.
## 한 틱을 못 채운 나머지는 다음 호출로 이월됩니다.
func advance(delta: float) -> int:
	_accumulated += delta

	var epsilon := _tick_seconds * EPSILON_RATIO
	var new_ticks := int((_accumulated + epsilon) / _tick_seconds)
	if new_ticks <= 0:
		return 0

	_accumulated = maxf(0.0, _accumulated - new_ticks * _tick_seconds)
	total_ticks += new_ticks
	return new_ticks
