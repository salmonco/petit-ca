"""배찌 스프라이트에서 부팅 스플래시(assets/splash.png)를 만든다.

    python3 tools/make_splash.py

게임 뷰포트와 같은 960x832 캔버스를 로비 배경색으로 채우고, 배찌를 6배
최근접 확대해 가운데 놓는다. 배율이 정수라야 원본 픽셀 하나가 모든 자리에서
같은 칸수를 차지한다.

배경색을 이미지에 구워 넣는 이유는, `boot_splash/bg_color` 로 지정한 여백
색과 이어 붙었을 때 경계가 안 보이게 하려는 것이다. 웹 셸은 이미지를
`object-fit: contain` 으로 놓으므로 화면 비율에 따라 위아래나 좌우에 여백이
생기는데, 두 색이 같으면 그 여백이 눈에 띄지 않는다.

crop_tile.py 와 같이 의존성 없이 zlib + struct 로 PNG 를 직접 다룬다.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from crop_tile import read_png
from make_icon import write_rgba_png

SOURCE = "assets/characters/bazzi_down.png"
OUTPUT = "assets/splash.png"
CROP = (0, 15, 64, 81)
SCALE = 6
CANVAS = (960, 832)
# scenes/lobby_view.tscn 의 Background ColorRect 와 같은 색.
BACKGROUND = (8, 56, 128, 255)


def main():
    width, height, channels, rows = read_png(SOURCE)
    if channels != 4:
        raise SystemExit(f"{SOURCE} 에 알파 채널이 없습니다")
    x0, y0, w, h = CROP
    if x0 + w > width or y0 + h > height:
        raise SystemExit(f"{SOURCE} ({width}x{height}) 밖을 자르려 합니다")

    canvas_w, canvas_h = CANVAS
    draw_w, draw_h = w * SCALE, h * SCALE
    if draw_w > canvas_w or draw_h > canvas_h:
        raise SystemExit(f"배찌({draw_w}x{draw_h})가 캔버스({canvas_w}x{canvas_h})보다 큽니다")
    left, top = (canvas_w - draw_w) // 2, (canvas_h - draw_h) // 2

    out = []
    for y in range(canvas_h):
        line = bytearray(bytes(BACKGROUND) * canvas_w)
        if top <= y < top + draw_h:
            sy = y0 + (y - top) // SCALE
            for x in range(draw_w):
                i = (x0 + x // SCALE) * channels
                r, g, b, a = rows[sy][i : i + 4]
                if a == 0:
                    continue
                j = (left + x) * 4
                if a == 255:
                    line[j : j + 4] = bytes((r, g, b, 255))
                else:
                    # 스프라이트 가장자리의 반투명 픽셀을 배경색 위에 올린다.
                    for k, value in enumerate((r, g, b)):
                        line[j + k] = (value * a + BACKGROUND[k] * (255 - a)) // 255
                    line[j + 3] = 255
        out.append(line)

    write_rgba_png(OUTPUT, canvas_w, canvas_h, out)
    print(f"{SOURCE} -> {OUTPUT} {canvas_w}x{canvas_h} (배찌 {draw_w}x{draw_h})")


if __name__ == "__main__":
    main()
