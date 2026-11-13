"""Нарезка героя-крестьянина по фактическим направлениям.

Лист: 9 колонок × 27 строк, ячейка 152×104.
Проверено по пикселям лица:
  строка 1  — лицо анфас, стойка (юг)
  строка 3  — корпус вправо, копьё вправо (восток)
  строка 7  — спина (север)
  строка 17 — выпад вправо/вперёд (атака, юг)
  строка 19 — выпад (восток)
  строка 23 — выпад, спина (север)
Запад получаем отражением восточных кадров.
"""
import os
from PIL import Image

SRC = r"C:\Users\slavk\Downloads\Telegram Desktop\medieval_peasant_man_bro-Idle.png"
OUT = r"C:\Users\slavk\Desktop\vibeode\kimdabollun\assets\sprites\hero"

CELL_W, CELL_H = 152, 104
FRAMES = 9

IDLE_ROW = {"s": 1, "e": 3, "n": 7}
ATTACK_ROW = {"s": 17, "e": 19, "n": 23}


def main():
    os.makedirs(OUT, exist_ok=True)
    for f in os.listdir(OUT):
        if f.endswith(".png"):
            os.remove(os.path.join(OUT, f))

    img = Image.open(SRC).convert("RGBA")

    for code, row in IDLE_ROW.items():
        for i in range(FRAMES):
            cell = img.crop((i * CELL_W, row * CELL_H, (i + 1) * CELL_W, (row + 1) * CELL_H))
            cell.save(f"{OUT}\\run_{code}_{i}.png")
        img.crop((0, row * CELL_H, CELL_W, (row + 1) * CELL_H)).save(f"{OUT}\\idle_{code}.png")

    for code, row in ATTACK_ROW.items():
        for i in range(FRAMES):
            cell = img.crop((i * CELL_W, row * CELL_H, (i + 1) * CELL_W, (row + 1) * CELL_H))
            cell.save(f"{OUT}\\atk_{code}_{i}.png")

    print("idle/run:", len(IDLE_ROW) * FRAMES, "attack:", len(ATTACK_ROW) * FRAMES)


main()
