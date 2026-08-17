"""스크린샷에서 잘라낸 조각을 타일 한 장(64x64 PNG)으로 만든다.

    python3 tools/crop_tile.py <원본.png> <출력.png> [x y 크기]

좌표를 생략하면 원본 전체를 한 칸으로 본다. 스크린샷에서 한 칸만 미리
잘라 두었다면 그 파일을 그대로 넘기면 된다.

원본이 64보다 크면 줄이면서 이웃 픽셀을 평균한다. 게임 화면을 확대해 캡처하면
보간 때문에 픽셀이 뭉개지는데, 줄이는 과정에서 그게 상당 부분 걷힌다.

의존성 없이 zlib + struct 로 PNG 를 직접 읽고 쓴다.
"""
import struct
import sys
import zlib

TILE_SIZE = 64


def read_png(path):
    data = open(path, "rb").read()
    pos, idat = 8, b""
    width = height = color_type = None
    while pos < len(data):
        length = struct.unpack(">I", data[pos : pos + 4])[0]
        tag = data[pos + 4 : pos + 8]
        payload = data[pos + 8 : pos + 8 + length]
        if tag == b"IHDR":
            width, height, _depth, color_type = struct.unpack(">IIBB", payload[:10])
        elif tag == b"IDAT":
            idat += payload
        pos += 12 + length

    channels = {0: 1, 2: 3, 4: 2, 6: 4}.get(color_type)
    if channels is None:
        raise SystemExit(f"지원하지 않는 PNG 색 방식입니다: color_type={color_type}")

    raw = zlib.decompress(idat)
    stride = width * channels
    rows, previous, pos = [], bytearray(stride), 0
    for _ in range(height):
        filter_type = raw[pos]
        line = bytearray(raw[pos + 1 : pos + 1 + stride])
        for i in range(stride):
            left = line[i - channels] if i >= channels else 0
            up = previous[i]
            up_left = previous[i - channels] if i >= channels else 0
            if filter_type == 1:
                line[i] = (line[i] + left) & 0xFF
            elif filter_type == 2:
                line[i] = (line[i] + up) & 0xFF
            elif filter_type == 3:
                line[i] = (line[i] + (left + up) // 2) & 0xFF
            elif filter_type == 4:
                pa, pb, pc = (
                    abs(up - up_left),
                    abs(left - up_left),
                    abs(left + up - 2 * up_left),
                )
                predictor = left if (pa <= pb and pa <= pc) else (up if pb <= pc else up_left)
                line[i] = (line[i] + predictor) & 0xFF
            elif filter_type != 0:
                raise SystemExit(f"알 수 없는 PNG 필터입니다: {filter_type}")
        rows.append(line)
        previous = line
        pos += 1 + stride
    return width, height, channels, rows


def write_png(path, size, rows):
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
        + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )
    with open(path, "wb") as f:
        f.write(png)


def crop_tile(src, x0, y0, span, channels, rows):
    tile = []
    for out_y in range(TILE_SIZE):
        line = bytearray()
        for out_x in range(TILE_SIZE):
            # 출력 픽셀 하나가 덮는 원본 영역을 평균낸다.
            sx0 = x0 + out_x * span // TILE_SIZE
            sx1 = max(sx0 + 1, x0 + (out_x + 1) * span // TILE_SIZE)
            sy0 = y0 + out_y * span // TILE_SIZE
            sy1 = max(sy0 + 1, y0 + (out_y + 1) * span // TILE_SIZE)
            total, count = [0, 0, 0], 0
            for sy in range(sy0, sy1):
                for sx in range(sx0, sx1):
                    i = sx * channels
                    total[0] += rows[sy][i]
                    total[1] += rows[sy][i + 1]
                    total[2] += rows[sy][i + 2]
                    count += 1
            line += bytes(round(value / count) for value in total)
        tile.append(line)
    return tile


def main(argv):
    if len(argv) not in (3, 6):
        raise SystemExit(__doc__)
    src, out = argv[1], argv[2]
    width, height, channels, rows = read_png(src)
    if len(argv) == 6:
        x0, y0, span = map(int, argv[3:6])
    else:
        x0 = y0 = 0
        span = min(width, height)
    if x0 + span > width or y0 + span > height:
        raise SystemExit(f"{src} ({width}x{height}) 밖을 자르려 합니다")

    write_png(out, TILE_SIZE, crop_tile(src, x0, y0, span, channels, rows))
    print(f"{src} ({x0},{y0}) {span}x{span} -> {out} {TILE_SIZE}x{TILE_SIZE}")


if __name__ == "__main__":
    main(sys.argv)
