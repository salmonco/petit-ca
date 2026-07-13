# Crazy Arcade — 작업 규칙

Godot 4.7 / GDScript / GdUnit4 6.1.3. **TDD로 진행합니다.**

## 아키텍처 원칙 (테스트 가능성이 여기서 결정됨)

- `src/core/` — 게임 규칙. `RefCounted` 기반. **엔진 의존 금지** (Node, 씬 트리, `_process` 없음).
  `Foo.new()`로 만들어 즉시 단언할 수 있어야 합니다. 로직의 대부분이 여기 있어야 정상입니다.
- `src/game/` — Node 레이어. 입력을 받고 `src/core/`를 호출하고 화면에 반영하는 **얇은 껍데기**.
- 도메인 로직은 시그널 대신 **값을 반환**하세요 (`func tick(delta) -> Array[Explosion]`).
  반환값은 바로 단언되지만 시그널은 구독하고 기다려야 합니다.

## 하네스 관련 함정 (실제로 겪은 것들)

- **`class_name`을 새로 추가하면 `godot --headless --path . --import`를 한 번 돌려야 합니다.**
  안 하면 `Identifier "Foo" not declared` 파싱 에러가 납니다.
- `bin/test.sh`에는 `-c`(fail-fast 해제)가 들어 있습니다. GdUnit4는 기본이 fail-fast라서
  첫 실패 시 스위트의 나머지 테스트를 실행하지 않고, 리포트에는 *실행된* 수만 찍혀
  테스트가 사라진 것처럼 보입니다.
- `--remote-debug tcp://127.0.0.1:0`도 필수입니다. 없으면 파싱 에러 시 Godot이 대화형
  디버거로 진입하면서 **종료 코드를 0으로 뭉갭니다** → CI가 깨진 빌드에 초록불을 줍니다.
- headless에서는 `InputEvent`가 전달되지 않습니다. 입력 시뮬레이션 테스트는 `bin/test.sh --gui`로.
  애초에 입력에 직접 의존하는 테스트를 만들지 않는 게 낫습니다.
- 시간/`delta` 기반 결과를 씬 테스트에서 단언하면 flaky합니다.
  시간 규칙은 `src/core/`에서 결정론적으로 테스트하세요.
- `simulate_frames(5)` 후 프레임 수를 **정확히 5**로 단언하지 마세요. `--gui` 로 창을 띄우면
  실제 엔진 루프도 프레임을 돌려서 더 커집니다. headless에서만 통과하는 테스트가 됩니다.
  `is_greater_equal(5)` 처럼 하한만 단언하세요.

## float 주의

시간·거리 누적에는 부동소수점 드리프트가 있습니다. `TickClock`이 이 버그로 처음에 깨졌습니다.
격자 좌표에는 `Vector2`(float) 대신 **`Vector2i`(정수)** 를 쓰세요.
