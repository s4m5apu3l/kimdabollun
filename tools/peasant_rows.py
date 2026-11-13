"""Раскладывает атлас medieval_peasant_man_bro по строкам.

Сетка: 9 колонок × 24 строки, ячейка 152×117.
Каждая строка сохраняется отдельной картинкой для разбора.
"""
import os
from PIL import Image

SRC = r"C:\Users\slavk\Downloads\Telegram Desktop\medieval_peasant_man_bro-Idle.png"
OUT = r"C:\Users\slavk\Desktop\vibeode\kimdabollun\assets\source\peasant_rows"

CELL_W, CELL_H = 152, 117
COLS = 9


def main():
    os.makedirs(OUT, exist_ok=True)
    img = Image.open(SRC).convert("RGBA")
    rows = img.height // CELL_H
    print("sheet", img.size, "rows", rows, "cols", img.width // CELL_W)

    for r in range(rows):
        row = img.crop((0, r * CELL_H, img.width, (r + 1) * CELL_H))
        row.save(f"{OUT}\\row_{r:02d}.png")

        # сколько кадров в строке реально заполнено и их общий bbox
        filled = 0
        box = None
        for c in range(COLS):
            cell = img.crop((c * CELL_W, r * CELL_H, (c + 1) * CELL_W, (r + 1) * CELL_H))
            b = cell.getbbox()
            if b:
                filled += 1
                if box is None:
                    box = [b[0], b[1], b[2], b[3]]
                else:
                    box = [min(box[0], b[0]), min(box[1], b[1]), max(box[2], b[2]), max(box[3], b[3])]
        print(f"row {r:02d}: frames={filled} bbox={box}")


main()
