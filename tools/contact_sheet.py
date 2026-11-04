"""Собирает контактный лист из тайлсета: каждый тайл 4x с номером.
Нужно, чтобы точно выбрать индексы тайлов для сцены.
"""
import sys
from PIL import Image, ImageDraw

src = sys.argv[1]
dst = sys.argv[2]
cell = int(sys.argv[3]) if len(sys.argv) > 3 else 16
margin = int(sys.argv[4]) if len(sys.argv) > 4 else 1
scale = int(sys.argv[5]) if len(sys.argv) > 5 else 4

img = Image.open(src).convert("RGBA")
pitch = cell + margin
cols = (img.width + margin) // pitch
rows = (img.height + margin) // pitch

pad = 14
out = Image.new("RGBA", (cols * (cell * scale + pad), rows * (cell * scale + pad)), (24, 26, 32, 255))
draw = ImageDraw.Draw(out)

for r in range(rows):
    for c in range(cols):
        x = c * pitch
        y = r * pitch
        tile = img.crop((x, y, x + cell, y + cell)).resize((cell * scale, cell * scale), Image.NEAREST)
        ox = c * (cell * scale + pad)
        oy = r * (cell * scale + pad)
        out.alpha_composite(tile, (ox, oy + pad))
        idx = r * cols + c
        # grid
        draw.rectangle([ox, oy + pad, ox + cell * scale - 1, oy + pad + cell * scale - 1], outline=(60, 66, 78, 255))
        draw.text((ox + 2, oy + 1), f"{idx}", fill=(240, 200, 90, 255))

out.convert("RGB").save(dst)
print(f"cols={cols} rows={rows} tiles={cols*rows} -> {dst}")
