#!/usr/bin/env python3
"""캐릭터 스프라이트에서 팀 색 교체용 마스크를 생성한다.

마스크는 "이 픽셀을 팀 색으로 갈아입힐 것인가"를 0~255로 적은 흑백 이미지다.
셰이더(`src/game/character_recolor.gdshader`)가 이 값으로 원본과 교체색을 섞는다.

원리는 팔레트 스왑이다. 옛 2D 게임은 인덱스 컬러라 팔레트 번호만 바꾸면 됐지만,
PNG로 저장하는 순간 그 번호를 잃는다. 그래서 색으로 역추적해 번호를 복원한다.

색 키 매칭은 런타임 셰이더에서 쓰면 경계가 지저분해지지만, 생성 시점에는 결과를
눈으로 보고 고칠 수 있어서 문제가 없다. 오히려 median 필터와 연결성분 정리를
얹을 수 있어 런타임보다 깨끗한 결과가 나온다.

사용법:
    python3 tools/make_masks.py                  # 전부 생성
    python3 tools/make_masks.py zomkkan          # 하나만
    python3 tools/make_masks.py --preview /tmp   # 대조표(원본|마스크|색 적용) 같이 저장

Pillow가 필요하다. 전역에 깔지 말고:
    python3 -m venv .venv && .venv/bin/pip install Pillow
    .venv/bin/python tools/make_masks.py

생성 후에는 Godot이 새 파일을 알아보도록 한 번 돌려야 한다:
    godot --headless --path . --import
"""

import argparse
import colorsys
import os
import sys

try:
    from PIL import Image, ImageFilter
except ImportError:
    sys.exit("Pillow가 필요합니다. 파일 맨 위 주석의 설치 방법을 보세요.")


# 캐릭터마다 갈아입힐 부위의 색이 다르므로 파라미터도 다르다.
# 값은 결과를 눈으로 보며 맞춘 것이니, 아트가 바뀌면 다시 맞춰야 한다.
#
#   hue    갈아입힐 부위의 목표 색상(도). 배찌는 빨간 후드, 좀깡은 분홍 셔츠.
#   inner  이 각도 안쪽은 확실히 그 부위 (마스크 1.0)
#   outer  이 각도 밖은 확실히 아님 (마스크 0.0). 사이는 선형으로 감쇠한다.
#   sat    채도 하한. 이보다 낮으면 무채색으로 보고 제외한다.
#          배찌 후드는 S≈1.0인 순정 빨강이라 높게 잡아도 되지만,
#          좀깡 셔츠는 연분홍 체크 무늬가 섞여 있어 낮춰야 무늬까지 잡힌다.
#   val    명도 하한. 검은 테두리가 색조를 띠고 있어도 걸러낸다.
#
# hue 창이 다른 부위와 충분히 떨어져 있으면 채도를 풀어줘도 안전하다.
# 좀깡이 그런 경우다 (셔츠 330° vs 몸 40~80°).
SPECS = {
    "bazzi": dict(
        dir="assets/characters",
        frames=["up", "down", "right", "bubble"],
        hue=0.0, inner=8.0, outer=16.0, sat=0.15, val=0.20,
    ),
    "zomkkan": dict(
        dir="assets/npcs",
        frames=["up", "down", "right", "bubble"],
        hue=330.0, inner=20.0, outer=34.0, sat=0.12, val=0.15,
    ),
}

# 이보다 작은 흰 섬 / 검은 구멍은 잡티로 보고 메운다.
DESPECKLE_MIN_PIXELS = 12


def _clamp01(x):
    return 0.0 if x < 0 else (1.0 if x > 1 else x)


def _hue_distance(hue, target_degrees):
    d = abs(hue * 360.0 - target_degrees) % 360.0
    return min(d, 360.0 - d)


def _score(r, g, b, spec):
    """이 픽셀이 갈아입힐 부위일 확률을 0.0~1.0으로."""
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    d = _hue_distance(h, spec["hue"])
    hue_score = _clamp01((spec["outer"] - d) / (spec["outer"] - spec["inner"]))
    sat_score = _clamp01((s - spec["sat"]) / 0.15)
    val_score = _clamp01(v / spec["val"])
    return hue_score * sat_score * val_score


def _components(bits, w, h):
    """4-이웃 연결 성분 라벨링. (라벨 배열, [(값, 크기)]) 를 돌려준다."""
    labels = [-1] * (w * h)
    comps = []
    for i in range(w * h):
        if labels[i] != -1:
            continue
        value = bits[i]
        cid = len(comps)
        labels[i] = cid
        stack = [i]
        size = 0
        while stack:
            p = stack.pop()
            size += 1
            x, y = p % w, p // w
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < w and 0 <= ny < h:
                    q = ny * w + nx
                    if labels[q] == -1 and bits[q] == value:
                        labels[q] = cid
                        stack.append(q)
        comps.append((value, size))
    return labels, comps


def build_mask(source_path, spec):
    """원본 PNG 경로를 받아 (원본 이미지, 마스크 이미지)를 돌려준다."""
    image = Image.open(source_path).convert("RGBA")
    w, h = image.size

    # 1) 색으로 1차 판정. 경계의 안티에일리어싱은 중간값으로 남는다.
    raw = [0.0] * (w * h)
    for i, (r, g, b, a) in enumerate(image.get_flattened_data()):
        if a >= 8:
            raw[i] = _score(r, g, b, spec) * (a / 255)

    # 2) 소금후추 잡티 제거. 원본이 부드럽게 확대된 이미지라 단색 픽셀이 거의 없다.
    gray = Image.new("L", (w, h))
    gray.putdata([int(round(255 * v)) for v in raw])
    smoothed = list(gray.filter(ImageFilter.MedianFilter(3)).get_flattened_data())

    # 3) 자잘한 흰 섬과 검은 구멍 메우기.
    bits = [1 if m >= 128 else 0 for m in smoothed]
    labels, comps = _components(bits, w, h)
    out = smoothed[:]
    for i in range(w * h):
        value, size = comps[labels[i]]
        if size < DESPECKLE_MIN_PIXELS:
            out[i] = 0 if value == 1 else 255

    mask = Image.new("L", (w, h))
    mask.putdata(out)
    return image, mask


def _on_checker(image, cell=8):
    """투명 배경을 체커보드로 깔아 눈으로 보기 좋게."""
    bg = Image.new("RGBA", image.size)
    px = []
    for y in range(image.size[1]):
        for x in range(image.size[0]):
            c = 210 if ((x // cell) + (y // cell)) % 2 == 0 else 165
            px.append((c, c, c, 255))
    bg.putdata(px)
    return Image.alpha_composite(bg, image)


def _recolor(image, mask, hue):
    """미리보기용. 셰이더와 같은 계산 — 채도·명도는 두고 색상만 교체한다."""
    src = list(image.get_flattened_data())
    mk = list(mask.get_flattened_data())
    out = []
    for i, (r, g, b, a) in enumerate(src):
        m = mk[i] / 255
        if m > 0:
            _, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            nr, ng, nb = colorsys.hsv_to_rgb(hue, s, v)
            r = int(r * (1 - m) + nr * 255 * m)
            g = int(g * (1 - m) + ng * 255 * m)
            b = int(b * (1 - m) + nb * 255 * m)
        out.append((r, g, b, a))
    preview = Image.new("RGBA", image.size)
    preview.putdata(out)
    return preview


def _write_preview(rows, path, scale=3):
    """원본 | 마스크 | 파랑 | 초록 | 노랑 대조표."""
    w, h = rows[0][0].size
    sheet = Image.new("RGBA", (w * 5, h * len(rows)))
    for i, (image, mask) in enumerate(rows):
        columns = [
            image,
            mask.convert("RGBA"),
            _recolor(image, mask, 210 / 360),
            _recolor(image, mask, 120 / 360),
            _recolor(image, mask, 50 / 360),
        ]
        for j, column in enumerate(columns):
            sheet.paste(_on_checker(column), (w * j, h * i))
    sheet = sheet.resize((sheet.width * scale, sheet.height * scale), Image.NEAREST)
    sheet.save(path)
    return path


def generate(name, preview_dir=None):
    spec = SPECS[name]
    rows = []
    for frame in spec["frames"]:
        source = os.path.join(spec["dir"], f"{name}_{frame}.png")
        if not os.path.exists(source):
            sys.exit(f"원본이 없습니다: {source}")
        image, mask = build_mask(source, spec)
        target = os.path.join(spec["dir"], f"{name}_{frame}_mask.png")
        mask.save(target)
        painted = sum(1 for v in mask.get_flattened_data() if v > 0)
        note = "  (빈 마스크 — 갈아입힐 부위가 안 보이는 프레임)" if painted == 0 else ""
        print(f"  {target}  {painted}px{note}")
        rows.append((image, mask))
    if preview_dir:
        path = _write_preview(rows, os.path.join(preview_dir, f"{name}_preview.png"))
        print(f"  미리보기: {path}")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("names", nargs="*", default=None,
                        help=f"대상 ({', '.join(SPECS)}). 비우면 전부")
    parser.add_argument("--preview", metavar="DIR",
                        help="대조표 PNG를 이 디렉터리에 저장한다")
    args = parser.parse_args()

    names = args.names or list(SPECS)
    for name in names:
        if name not in SPECS:
            sys.exit(f"모르는 대상: {name} (가능: {', '.join(SPECS)})")

    for name in names:
        print(f"{name}:")
        generate(name, args.preview)

    print("\nGodot이 새 파일을 알아보게 하려면: godot --headless --path . --import")


if __name__ == "__main__":
    main()
