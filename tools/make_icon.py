"""배찌 스프라이트에서 앱 아이콘(assets/icon.png)을 만든다.

    python3 tools/make_icon.py

`assets/characters/bazzi_down.png`의 머리 부분(y 15..78, 64x64)을 잘라
4배 최근접 확대한 256x256 PNG를 쓴다. 배율이 정수라야 원본 픽셀 하나가
모든 자리에서 같은 칸수를 차지한다. 3.75배 같은 소수 배율은 어떤 픽셀은
3칸 어떤 픽셀은 4칸이 되어 픽셀아트가 울퉁불퉁해진다.

`application/config/icon` 이 이 파일을 가리킨다. Godot 은 웹 export 때
favicon(index.icon.png)으로 원본 크기 그대로 내보내고, apple-touch-icon
은 180x180 으로 줄인다.

crop_tile.py 와 같이 의존성 없이 zlib + struct 로 PNG 를 직접 다룬다.
"""
import os
import struct
import sys
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from crop_tile import read_png

SOURCE = "assets/characters/bazzi_down.png"
OUTPUT = "assets/icon.png"
CROP = (0, 15, 64, 64)
SCALE = 4


def write_rgba_png(path, width, height, rows):
    raw = b"".join(b"\x00" + bytes(row) for row in rows)

    def chunk(tag, data):
        return (
            struct.pack(">I", len(data))
            + tag
            + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )
    with open(path, "wb") as f:
        f.write(png)


def main():
    width, height, channels, rows = read_png(SOURCE)
    if channels != 4:
        raise SystemExit(f"{SOURCE} 에 알파 채널이 없습니다")
    x0, y0, span, _ = CROP
    if x0 + span > width or y0 + span > height:
        raise SystemExit(f"{SOURCE} ({width}x{height}) 밖을 자르려 합니다")

    size = span * SCALE
    out = []
    for y in range(size):
        line = bytearray()
        for x in range(size):
            i = (x0 + x // SCALE) * channels
            line += bytes(rows[y0 + y // SCALE][i : i + 4])
        out.append(line)

    write_rgba_png(OUTPUT, size, size, out)
    print(f"{SOURCE} ({x0},{y0}) {span}x{span} -> {OUTPUT} {size}x{size}")


if __name__ == "__main__":
    main()
