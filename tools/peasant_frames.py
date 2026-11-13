"""Режет новый герой (medieval_peasant_man_bro) на кадры.

Сетка листа: 9 колонок × 24 строки, ячейка 152×117.
  строка 0      — стойка в 8 направлениях (по кадрам)
  строки 1..8   — ходьба в 8 направлениях, по 9 кадров
Порядок направлений как в прошлом атласе: s, se, e, ne, n, nw, w, sw.
Ступни в ячейке на y=81.
"""
import os
from PIL import Image

SRC = r"C:\Users\slavk\Downloads\Telegram Desktop\medieval_peasant_man_bro-Idle.png"
OUT = r"C:\Users\slavk\Desktop\vibeode\kimdabollun\assets\sprites\hero"

CELL_W, CELL_H = 152, 117
CODES = ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
WALK_FRAMES = 6


def main():
    os.makedirs(OUT, exist_ok=True)
    img = Image.open(SRC).convert("RGBA")

    for i, code in enumerate(CODES):
        idle = img.crop((i * CELL_W, 0, (i + 1) * CELL_W, CELL_H))
        idle.save(f"{OUT}\\idle_{code}.png")

    for i, code in enumerate(CODES):
        row = 1 + i
        for f in range(WALK_FRAMES):
            cell = img.crop((f * CELL_W, row * CELL_H, (f + 1) * CELL_W, (row + 1) * CELL_H))
            cell.save(f"{OUT}\\run_{code}_{f}.png")

    print("idle", len(CODES), "run", len(CODES) * WALK_FRAMES)


main()
