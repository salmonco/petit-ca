# GDScript 사용법 — 도메인 모델을 직접 짜기 위한 최소 지식

도메인 설계는 지수님이 하시고 제가 리뷰하는 구조라, 여기엔 **문법과 함정**만 담았습니다.
게임 규칙을 표현할 때 실제로 쓰게 될 것들 위주입니다.

---

## 1. 가장 중요한 것: RefCounted vs Node

TDD의 성패가 여기서 갈립니다.

```gdscript
class_name Bomb
extends RefCounted     # 씬 트리 없음. new()로 만들고 바로 테스트 가능. 밀리초 단위.
```

```gdscript
class_name BombNode
extends Node2D         # 씬 트리 필요. 렌더링·물리·_process에 묶임. 테스트가 무겁고 느림.
```

**규칙: 게임 "규칙"은 `RefCounted`로, 화면에 보이는 것만 `Node`로.**

폭탄이 몇 초 뒤 터지는지, 폭발이 몇 칸 뻗는지, 벽에 막히는지 — 전부 순수 계산입니다.
`Node`에 넣으면 테스트하려고 씬을 띄우고 프레임을 돌려야 하지만,
`RefCounted`에 넣으면 `Bomb.new()` 한 줄로 끝납니다.

`RefCounted`는 참조 카운팅으로 자동 해제됩니다 (`free()` 불필요).
`Object`를 직접 상속하면 수동 해제해야 하고 테스트에서 메모리 누수(orphan)로 잡히니 쓰지 마세요.

---

## 2. 타입 표기 — 반드시 쓰세요

```gdscript
var speed: float = 3.0        # 명시적 타입
var tiles := 5                # := 는 타입 추론 (int으로 확정됨)
var loose = 5                 # 타입 없음. 하지 마세요.
```

`:=`나 `: Type`을 쓰면 Godot이 **컴파일 타임에 타입 오류를 잡아주고**, 실행도 빨라집니다.
타입 없는 변수는 오타가 런타임까지 살아남습니다.

함수도 마찬가지:

```gdscript
func explode(radius: int) -> Array[Vector2i]:
	return []
```

반환값이 없으면 `-> void`를 명시하세요.

---

## 3. 그리드 게임에서 제일 많이 쓸 타입

```gdscript
var cell: Vector2i = Vector2i(3, 4)      # 정수 좌표 — 격자 칸에 딱 맞음
var pos: Vector2 = Vector2(3.5, 4.2)     # 실수 좌표 — 화면상 위치

cell + Vector2i(1, 0)                    # 오른쪽 칸
cell.x, cell.y
```

격자 로직에는 **`Vector2i`(정수)** 를 쓰세요. `Vector2`(float)로 칸을 세면
부동소수점 오차 때문에 `Vector2(1.0, 0.0) == Vector2(0.9999, 0.0)`이 false가 되어
"같은 칸인데 다른 칸"이 됩니다.

방향 상수는 이렇게:

```gdscript
const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT,
]
```

---

## 4. 컬렉션

```gdscript
var bombs: Array[Bomb] = []              # 타입 붙은 배열 — 원소 타입까지 검사됨
bombs.append(bomb)
bombs.erase(bomb)
bombs.size()
bomb in bombs                            # 포함 여부

var grid: Dictionary = {}                # 키→값
grid[Vector2i(1, 2)] = Tile.WALL
grid.has(Vector2i(1, 2))
grid.get(Vector2i(1, 2), Tile.EMPTY)     # 기본값과 함께 조회
grid.erase(Vector2i(1, 2))
```

`Dictionary`의 키로 `Vector2i`를 쓸 수 있습니다 — 격자 맵 표현에 아주 편합니다.
(단 `Dictionary`는 타입 파라미터가 없어서 원소 타입 검사가 안 됩니다.)

---

## 5. enum — 상태 표현

```gdscript
enum Tile { EMPTY, WALL, BOX, BOMB }
enum PlayerState { ALIVE, TRAPPED, DEAD }

var state: PlayerState = PlayerState.ALIVE
```

enum은 내부적으로 int입니다. `match`로 분기하세요:

```gdscript
match state:
	PlayerState.ALIVE:
		pass
	PlayerState.TRAPPED, PlayerState.DEAD:   # 여러 값 한 번에
		pass
	_:                                        # default
		pass
```

---

## 6. 생성자와 기본 인자

```gdscript
class_name Bomb
extends RefCounted

var cell: Vector2i
var power: int
var fuse: float

func _init(cell_: Vector2i, power_: int = 1, fuse_: float = 3.0) -> void:
	cell = cell_
	power = power_
	fuse = fuse_
```

`Bomb.new(Vector2i(2, 3))` 또는 `Bomb.new(Vector2i(2, 3), 4, 2.5)`로 생성.
GDScript엔 생성자 오버로딩이 없으니 **기본 인자**로 해결합니다.

이름 충돌을 피하려고 파라미터에 `_` 접미사를 붙이는 게 관행입니다
(`cell_`). 접두사 `_cell`은 "private" 관행이라 의미가 겹칩니다.

---

## 7. 시그널 — Node 레이어에서만

```gdscript
signal exploded(cell: Vector2i, affected: Array[Vector2i])

exploded.emit(cell, cells)          # 발신
bomb.exploded.connect(_on_exploded) # 수신
```

**도메인 로직(RefCounted)에서는 시그널 대신 값을 반환하세요.**
`func tick(delta: float) -> Array[Explosion]` 처럼요.
반환값은 테스트에서 바로 단언할 수 있지만, 시그널은 구독하고 기다려야 합니다.
시그널은 "엔진에 알리는" 바깥 껍데기에서만 쓰면 충분합니다.

---

## 8. @export / @onready — Node 전용

```gdscript
extends Node2D

@export var move_speed: float = 120.0     # 에디터 인스펙터에 노출
@onready var sprite: Sprite2D = $Sprite2D # _ready 시점에 자식 노드 참조
```

`@onready`는 `_ready()` 직전에 대입됩니다. `_init()`에서는 아직 null입니다.

---

## 9. 반드시 알아야 할 함정들

**정수 나눗셈**
```gdscript
7 / 2        # → 3  (둘 다 int면 정수 나눗셈!)
7 / 2.0      # → 3.5
float(7) / 2 # → 3.5
```

**float 비교**
```gdscript
0.1 + 0.2 == 0.3          # false!
is_equal_approx(0.1 + 0.2, 0.3)   # true
```
이 프로젝트의 `TickClock`이 정확히 이 문제로 처음에 테스트가 깨졌습니다
([tick_clock.gd](../src/core/tick_clock.gd)의 `EPSILON_RATIO` 참고).
시간·거리 누적에는 항상 이 함정이 있습니다.

**배열은 참조로 전달됩니다**
```gdscript
var a := [1, 2]
var b := a
b.append(3)      # a도 [1, 2, 3]이 됩니다
var c := a.duplicate()   # 복사가 필요하면 명시적으로
```

**Array[T]는 원소 타입을 런타임에도 검사합니다**
```gdscript
var bombs: Array[Bomb] = []
bombs.append("not a bomb")   # 런타임 에러
```

**`null` 체크**
```gdscript
if node != null:              # RefCounted/일반 객체
if is_instance_valid(node):   # 이미 free된 Node일 수 있을 때
```

---

## 10. 테스트에서 쓸 GdUnit4 단언 치트시트

```gdscript
extends GdUnitTestSuite

func test_something() -> void:
	assert_int(3).is_equal(3)
	assert_int(3).is_greater(2)
	assert_int(3).is_between(1, 5)

	assert_float(0.3).is_equal_approx(0.1 + 0.2, 0.0001)

	assert_bool(true).is_true()

	assert_str("bomb").contains("bo")

	assert_array([1, 2, 3]).contains([2])
	assert_array([1, 2, 3]).has_size(3)
	assert_array([1, 2]).is_empty()

	assert_dict({"a": 1}).contains_keys(["a"])

	assert_object(bomb).is_not_null()
	assert_object(bomb).is_instanceof(Bomb)

	# 시그널 (Node 레이어)
	await assert_signal(node).is_emitted("exploded")
```

테스트 함수 이름은 **반드시 `test_`로 시작**해야 발견됩니다.
한글 이름도 정상 동작합니다 (`func test_폭탄이_3초뒤_터진다()`) — 검증했습니다.

---

## 11. 씬 테스트 (프레임 시뮬레이션)

```gdscript
var runner := scene_runner("res://scenes/foo.tscn")
var node: Foo = runner.scene()

await runner.simulate_frames(10)       # 10프레임 강제 진행
runner.invoke("some_method", arg)
runner.set_property("hp", 3)
```

**주의**: headless 모드에서는 Godot이 `InputEvent`를 전달하지 않습니다.
`simulate_key_pressed()` 같은 입력 시뮬레이션은 `bin/test.sh --gui`로 창을 띄워야 실제로 동작합니다.
가능하면 입력 테스트 자체를 피하고, "키 → 의도(Intent)" 변환만 얇게 두세요.

---

## 12. 참고

- GDScript 공식 레퍼런스: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- GdUnit4 문서: https://mikeschulze.github.io/gdUnit4/
