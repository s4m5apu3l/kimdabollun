"""Режет новый атлас героя (Pixel_art_character_chib-Idle) по JSON-манифесту.

Ячейка 96×96, 8 колонок. Ряд 0 — стойка в 8 направлениях,
ряды 1..8 — бег в 8 направлениях по 6 кадров.
"""
import json
from PIL import Image

SRC_DIR = r"C:\Users\slavk\Downloads\Telegram Desktop"
PROJ = r"C:\Users\slavk\Desktop\vibeode\kimdabollun"
OUT = PROJ + r"\assets\sprites\hero"

CODES = {
    "south": "s", "south-east": "se", "east": "e", "north-east": "ne",
    "north": "n", "north-west": "nw", "west": "w", "south-west": "sw",
}


def main():
    with open(SRC_DIR + r"\Pixel_art_character_chib-Idle.json", encoding="utf-8") as f:
        data = json.load(f)

    sheet = data["spritesheet"]
    cw = sheet["cell_size"]["width"]
    ch = sheet["cell_size"]["height"]
    cols = sheet["columns"]

    img = Image.open(SRC_DIR + "\\" + sheet["path"]).convert("RGBA")

    for row in sheet["rows"]:
        r = row["row"]
        count = row["frame_count"]
        if row["type"] == "rotations":
            for i, direction in enumerate(row["directions"]):
                code = CODES[direction]
                cell = img.crop((i * cw, r * ch, i * cw + cw, r * ch + ch))
                cell.save(f"{OUT}\\idle_{code}.png")
        else:
            code = CODES[row["direction"]]
            for i in range(count):
                cell = img.crop((i * cw, r * ch, i * cw + cw, r * ch + ch))
                cell.save(f"{OUT}\\run_{code}_{i}.png")
        print("row", r, row.get("type"), row.get("direction", ""), "->", count)


main()
