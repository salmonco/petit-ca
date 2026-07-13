# TDD 예시 테스트 — 구현(src/core/tick_clock.gd)보다 먼저 작성됐습니다.
#
# TickClock: 가변 delta(프레임마다 들쭉날쭉함)를 고정 스텝 "틱"으로 바꿔주는 누산기.
# 폭탄 타이머처럼 "몇 초 뒤에 터진다"는 로직을 프레임레이트와 무관하게,
# 그리고 엔진 없이 테스트 가능하게 만들려면 이런 순수 계산 객체가 필요합니다.
extends GdUnitTestSuite


func test_한_틱을_채우기_전에는_틱이_발생하지_않는다() -> void:
	var clock := TickClock.new(0.1)

	assert_int(clock.advance(0.05)).is_equal(0)
	assert_int(clock.total_ticks).is_equal(0)


func test_여러_번의_delta가_누적되어_틱을_만든다() -> void:
	var clock := TickClock.new(0.1)

	assert_int(clock.advance(0.06)).is_equal(0)
	assert_int(clock.advance(0.06)).is_equal(1)  # 0.12 누적 → 1틱
	assert_int(clock.total_ticks).is_equal(1)


func test_큰_delta는_여러_틱을_한번에_만든다() -> void:
	var clock := TickClock.new(0.1)

	assert_int(clock.advance(0.35)).is_equal(3)
	assert_int(clock.total_ticks).is_equal(3)


func test_틱을_만들고_남은_나머지는_다음_호출로_이월된다() -> void:
	var clock := TickClock.new(0.1)

	clock.advance(0.35)  # 3틱 소비, 0.05 남음
	assert_int(clock.advance(0.05)).is_equal(1)  # 남은 0.05 + 0.05 = 0.1 → 1틱


func test_틱_길이는_생성자로_주입된다() -> void:
	var slow := TickClock.new(1.0)

	assert_int(slow.advance(0.9)).is_equal(0)
	assert_int(slow.advance(0.2)).is_equal(1)


# 회귀 테스트. 위의 "이월" 테스트가 처음에 실제로 실패해서 잡아낸 버그입니다:
# float 나눗셈의 나머지가 0.049999999999999996 처럼 미세하게 작게 남으면
# 다음 틱의 경계를 영원히 못 넘고, 오차가 누적되어 틱이 조금씩 밀립니다.
# 게임으로 치면 폭탄이 제때 안 터지는 버그입니다.
func test_많은_프레임_후에도_틱이_밀리지_않는다() -> void:
	var clock := TickClock.new(1.0 / 60.0)
	var frame_delta := 1.0 / 60.0

	for i in 600:
		clock.advance(frame_delta)

	assert_int(clock.total_ticks).is_equal(600)

