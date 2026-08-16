"""크아풍 버튼 텍스처(9슬라이스용)를 굽는다.

    python3 tools/make_button.py <출력 디렉터리>

구조는 크레이지 아케이드 로비의 `방만들기` 버튼에서 그대로 가져왔다.
바깥부터 흰 외곽선 → 주황빨강 테두리 → 위아래 노랑 그라데이션이고,
비스듬한 줄무늬가 아주 옅게 깔린다.

64x64 로 굽고 모서리 16px 를 9슬라이스 여백으로 쓴다. 가운데만 늘어나므로
버튼 크기가 달라져도 테두리 두께와 모서리 곡률이 유지된다.

의존성 없이 zlib + struct 로 PNG(RGBA) 를 직접 쓴다.
"""
import struct
import sys
import zlib

SIZE = 64
RADIUS = 14
OUTLINE = 3  # 흰 외곽선 두께
FRAME = 3  # 주황빨강 테두리 두께

WHITE = (250, 250, 250)
FRAME_COLOR = (232, 88, 16)

# (위 색, 아래 색) — 채움의 세로 그라데이션
FILLS = {
	"normal": ((255, 233, 120), (248, 160, 16)),
	"hover": ((255, 245, 180), (250, 190, 40)),
	"pressed": ((236, 176, 24), (248, 214, 60)),
	"disabled": ((198, 206, 214), (150, 164, 180)),
}
DISABLED_FRAME = (120, 134, 150)


def write_png(path, rows):
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
		+ chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 6, 0, 0, 0))
		+ chunk(b"IDAT", zlib.compress(raw, 9))
		+ chunk(b"IEND", b"")
	)
	with open(path, "wb") as f:
		f.write(png)


def inset_distance(x, y):
	"""모서리가 둥근 사각형에서 테두리까지의 거리. 밖이면 음수."""
	cx = min(x, SIZE - 1 - x)
	cy = min(y, SIZE - 1 - y)
	if cx >= RADIUS or cy >= RADIUS:
		return min(cx, cy)
	dx = RADIUS - cx
	dy = RADIUS - cy
	return RADIUS - (dx * dx + dy * dy) ** 0.5


def mix(a, b, t):
	return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def make_button(name):
	top, bottom = FILLS[name]
	frame = DISABLED_FRAME if name == "disabled" else FRAME_COLOR
	rows = []
	for y in range(SIZE):
		line = bytearray()
		for x in range(SIZE):
			depth = inset_distance(x, y)
			if depth < 0:
				line += bytes((0, 0, 0, 0))
				continue
			if depth < OUTLINE:
				line += bytes(WHITE + (255,))
				continue
			if depth < OUTLINE + FRAME:
				line += bytes(frame + (255,))
				continue
			color = mix(top, bottom, y / (SIZE - 1))
			# 비스듬한 줄무늬. 눈에 겨우 걸릴 만큼만 밝힌다.
			if (x + y) % 8 < 3:
				color = mix(color, (255, 255, 255), 0.10)
			line += bytes(color + (255,))
		rows.append(line)
	return rows


def main(out_dir):
	for name in FILLS:
		write_png(f"{out_dir}/button_{name}.png", make_button(name))
	print(f"wrote button_{'/'.join(FILLS)}.png to {out_dir}")


if __name__ == "__main__":
	main(sys.argv[1])
