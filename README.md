# Crazy Arcade

크아 게임 만들기

Godot 4.7 + GDScript + GdUnit4

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
