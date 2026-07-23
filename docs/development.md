# 개발 가이드

Godot 4.7 + GDScript + GdUnit4 6.1.3.

이 문서는 "어떻게 돌리는가"와 "무엇을 뭐라고 부르는가"를 다룹니다.
**어떻게 짜는가는 저장소 루트의 `CLAUDE.md`에 있습니다.** 아키텍처 원칙, 좌표계 규칙,
테스트 작성 규칙이 거기 있고, 코드를 건드리기 전에 읽어야 합니다.

## 셋업

```bash
brew install --cask godot     # 4.7
```

## 실행

```bash
./run -h                            # 사용법
./run                               # 게임 실행 (project.godot 의 main_scene)
./run scenes/frame_counter.tscn     # 특정 씬만 실행
./run -e                            # Godot 에디터 열기
```

VSCode에서 개발할 때 Godot 에디터를 띄워두세요. 자동완성과 문법 에러 빨간 밑줄이 여기서 나옵니다.
GDScript의 언어 서버(LSP)는 독립 실행되지 않고 Godot 에디터 안에 들어 있습니다(`127.0.0.1:6005`).

## 테스트

```bash
./t -h                             # 사용법
./t                                # 전체
./t test/core                      # 디렉터리
./t test/core/water_balloon_test.gd  # 파일 하나
./t -w                             # 감시 모드
./t -w -g test/game                # 감시 + 창
./t --clean                        # reports/ 와 .godot/ 캐시 삭제
```

`./t`와 `./run`은 각각 `bin/test.sh`, `bin/run.sh`를 부르는 한 줄짜리 단축 실행기입니다.
플래그는 자유롭게 조합됩니다. Godot 실행 파일을 찾는 로직은 `bin/_godot.sh`에 한 번만 두고
둘이 공유합니다.

테스트 로그 맨 위에 뜨는 `Remote Debugger: Unable to connect` 두 줄은 정상입니다.
왜 정상인지는 `CLAUDE.md`의 "하네스 관련 함정"에 적어뒀습니다.

## 구조

```
src/core/     게임 규칙. RefCounted 기반, 엔진 의존 없음. 로직 대부분이 여기 살아야 함
src/game/     Node 레이어. 엔진에 배선하는 얇은 껍데기
scenes/       .tscn 씬 파일
test/core/    순수 로직 테스트 (빠름, 결정론적)
test/game/    씬 테스트 (scene_runner로 프레임 시뮬레이션)
docs/         개발 문서
addons/gdUnit4/  테스트 프레임워크 (v6.1.3, 커밋에 포함)
```

`src/core/`와 `src/game/`의 경계가 이 프로젝트에서 가장 중요한 선입니다. 그 선을 왜 그었고
어떻게 지키는지는 `CLAUDE.md`를 보세요.

## 용어

도메인은 한국어, 코드는 영어입니다. 그 사이의 환산표를 여기 둡니다.
**새 개념의 이름은 이 표에서 가져오고, 표에 없으면 표부터 갱신하세요.**
즉석에서 지으면 같은 것을 두 낱말로 부르게 됩니다.

| 도메인 | 코드 | 뜻 |
|---|---|---|
| 칸 | `Vector2i` | 격자 좌표(칸 번호). 화면 좌표는 `Vector2`(픽셀) |
| 맵 | `Map` | 격자와 그 위에 놓인 것들 |
| 캐릭터 | `Character` | 칸 단위로 움직이고 물풍선을 놓는다 |
| NPC | `Npc` | 컴퓨터가 조종하는 캐릭터. 스스로 다음 칸 방향을 정한다 (크아 협공배틀의 좀깡 같은) |
| 물풍선 | `WaterBalloon` | 캐릭터가 칸에 놓는 것. 시간이 지나면 터진다 |
| 터지다 | `pop` | `POP_AFTER_SECONDS`, `popped` |
| 놓은 이 | `placed_by` | 그 물풍선을 놓은 캐릭터. 터질 때 이 캐릭터의 한도가 돌아온다 |
| 물줄기 | `WaterStream` | 물줄기의 한 칸(타일). `DURATION` 동안 남는다 |
| 물방울 | `Bubble` | 물줄기에 맞은 캐릭터가 갇히는 상태. `ALIVE_SECONDS` 뒤에 터진다 |
| 갇히다 | `trap` | 캐릭터가 물방울에 들어가는 것. `is_trapped`, `trapped()` |
| 아웃 | `out` | 물방울에서 빠져나오지 못한 캐릭터가 맵에서 사라지는 것. `is_out`, `out()` |
| 게임 오버 | `game_over` | 맵에 캐릭터가 하나도 남지 않아 게임이 끝난 상태 |
| 승 / 패 | `win` / `lose` | 게임 오버의 결과. **캐릭터가 여럿이 되기 전에는 패밖에 없다** |
| 배틀 | `Battle` | 한 판의 대국. 맵을 소유하고 승패를 판정한다 |
