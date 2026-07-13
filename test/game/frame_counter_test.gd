# Node 레이어 테스트 예시 — scene_runner로 실제 씬을 띄우고 프레임을 강제로 돌립니다.
# GdUnit4를 고른 이유가 이겁니다: 게임 루프를 기다리지 않고 프레임을 "밀어서" 검증합니다.
#
# 주의: 여기서는 시간(delta) 기반 결과를 단언하지 않습니다.
# 시뮬레이션된 프레임의 delta는 실제 벽시계 시간이라 매번 미묘하게 다르고,
# 그걸 단언하면 테스트가 flaky해집니다.
#
# 그래서 역할을 나눕니다:
#   - "몇 초 뒤에 터지는가" 같은 시간 규칙 → src/core/ 의 순수 객체에서 결정론적으로 테스트
#   - "노드가 엔진에 제대로 배선됐는가" → 여기서 테스트
extends GdUnitTestSuite

const SCENE_PATH := "res://scenes/frame_counter.tscn"


func test_프레임을_시뮬레이션하면_process가_호출된다() -> void:
	var runner := scene_runner(SCENE_PATH)
	var counter: FrameCounter = runner.scene()

	assert_int(counter.frames).is_equal(0)

	await runner.simulate_frames(5)

	# "정확히 5"가 아니라 "최소 5"입니다.
	# --gui 로 창을 띄우면 실제 엔진 루프도 프레임을 돌리기 때문에 5보다 커집니다.
	# 정확한 수를 단언하면 headless에서는 통과하고 창 모드에서는 깨지는,
	# 환경에 의존하는 테스트가 됩니다.
	assert_int(counter.frames).is_greater_equal(5)


func test_노드가_TickClock에_배선되어_있다() -> void:
	var runner := scene_runner(SCENE_PATH)
	var counter: FrameCounter = runner.scene()

	# _ready()에서 TickClock이 만들어졌는지 (틱은 아직 0)
	assert_int(counter.total_ticks()).is_equal(0)

	# 틱 길이를 아주 짧게 두면 프레임을 돌릴 때 반드시 틱이 쌓입니다.
	# "정확히 몇 틱"이 아니라 "틱이 발생한다"만 단언합니다 — delta에 의존하지 않으려고.
	counter.tick_seconds = 0.0001
	counter._ready()
	await runner.simulate_frames(10)

	assert_int(counter.total_ticks()).is_greater(0)
