# Petit Crazy Arcade

<쁘띠크아>는 크아의 손맛을 되살린 **2D 아케이드 게임**입니다.

## 제작 배경
2026년 8월 13일은 크아 서비스 종료일입니다.
고이 잠들 크아에서의 손맛을 깨우기 위해 직접 만들기로 했습니다.

## 게임 방법
### 목표
상대방을 물풍선으로 가둬 아웃시켜야 합니다.
### 조작 방법
- 자신의 캐릭터를 키보드 방향키(상·하·좌·우)로 이동시킬 수 있습니다.
- 스페이스 바를 눌러 물풍선을 놓을 수 있습니다.
### 종료 조건
상대방이 모두 아웃되면 종료됩니다.

## 셋업

```bash
brew install --cask godot     # 이미 설치됨 (4.7)
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
./t test/core/tick_clock_test.gd   # 파일 하나
./t -w                             # 감시 모드
./t -w -g test/game                # 감시 + 창
./t --clean                        # reports/ 와 .godot/ 캐시 삭제
```

`./t`와 `./run`은 각각 `bin/test.sh`, `bin/run.sh`를 부르는 한 줄짜리 단축 실행기입니다.
플래그는 자유롭게 조합됩니다. Godot 실행 파일을 찾는 로직은 `bin/_godot.sh`에 한 번만 두고 둘이 공유합니다.

## 구조

```
src/core/     게임 규칙. RefCounted 기반, 엔진 의존 없음. ← 로직 대부분이 여기 살아야 함
src/game/     Node 레이어. 엔진에 배선하는 얇은 껍데기.
scenes/       .tscn 씬 파일
test/core/    순수 로직 테스트 (빠름, 결정론적)
test/game/    씬 테스트 (scene_runner로 프레임 시뮬레이션)
addons/gdUnit4/  테스트 프레임워크 (v6.1.3, 커밋에 포함)
```

Godot 4.7 + GDScript + GdUnit4로 작성되었습니다.
