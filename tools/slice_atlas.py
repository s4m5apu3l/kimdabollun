"""Разбирает атлас героя на кадры по пустым промежуткам.

1) находит горизонтальные полосы (анимации),
2) внутри полосы — вертикальные промежутки (кадры),
3) сохраняет отладочную картинку с рамками и номерами.
"""
import sys
from PIL import Image, ImageDraw

src = sys.argv[1]
debug = sys.argv[2]

img = Image.open(src).convert("RGBA")
w, h = img.size
px = img.load()

has_alpha = any(px[x, y][3] < 250 for x in range(0, w, 7) for y in range(0, h, 7))
if has_alpha:
    mask = [[px[x, y][3] > 16 for y in range(h)] for x in range(w)]
else:
    bg = px[0, 0][:3]
    mask = [[sum(abs(px[x, y][i] - bg[i]) for i in range(3)) > 24 for y in range(h)] for x in range(w)]

print("has_alpha:", has_alpha, "bg:", px[0, 0])


def col_has(x, y0, y1):
    return any(mask[x][y] for y in range(y0, y1))


def row_has(y, x0, x1):
    return any(mask[x][y] for x in range(x0, x1))


# Полосы сверху вниз
bands = []
y = 0
while y < h:
    if row_has(y, 0, w):
        y0 = y
        while y < h and row_has(y, 0, w):
            y += 1
        bands.append((y0, y))
    else:
        y += 1

print("bands:", len(bands))
frames = []
for bi, (y0, y1) in enumerate(bands):
    runs = []
    x = 0
    while x < w:
        if col_has(x, y0, y1):
            x0 = x
            while x < w and col_has(x, y0, y1):
                x += 1
            runs.append((x0, x))
        else:
            x += 1
    print(f"  band {bi}: y={y0}..{y1} h={y1-y0} frames={len(runs)}")
    for (x0, x1) in runs:
        frames.append((bi, x0, y0, x1, y1))

out = img.copy()
d = ImageDraw.Draw(out)
for i, (bi, x0, y0, x1, y1) in enumerate(frames):
    d.rectangle([x0, y0, x1 - 1, y1 - 1], outline=(255, 80, 80, 255))
    d.text((x0 + 2, y0 + 2), f"{bi}:{i}", fill=(255, 230, 120, 255))
out.convert("RGB").save(debug)
print("frames:", len(frames), "->", debug)
for i, f in enumerate(frames):
    print(i, f, "size", f[3] - f[1], "x", f[4] - f[2])
