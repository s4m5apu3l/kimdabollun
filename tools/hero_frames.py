"""Режет атлас героя на кадры по направлениям.

Полосы атласа (y) и кадры (x) определены по пустым промежуткам:
  ряд 1: 253..409 — ходьба
  ряд 2: 434..578 — атаки
Кадры уменьшаются ровно в 2 раза (пиксель-в-пиксель), выравниваются
по нижней кромке и центру на общий холст.
"""
from PIL import Image

SRC = r"C:\Users\slavk\Downloads\Пиксельный атлас воина-разбойника.png"
DST = r"C:\Users\slavk\Desktop\vibeode\kimdabollun\assets\sprites\hero"

WALK_Y = (253, 409)
ATTACK_Y = (434, 578)

# Границы кадров из разбора пустых промежутков.
WALK_FRAMES = [
    (32, 134), (168, 261), (286, 383), (409, 505),      # вниз
    (525, 600), (622, 710), (746, 819), (840, 921),     # вбок
    (944, 1035), (1062, 1133), (1140, 1217), (1228, 1304), (1316, 1394), (1410, 1492),
]
ATTACK_FRAMES = [
    (14, 113), (138, 248), (265, 382), (409, 537), (579, 724), (727, 919),
    (937, 1126), (1181, 1332), (1379, 1528),
]

CANVAS = (72, 88)


def load():
    return Image.open(SRC).convert("RGBA")


def cut(img, x0, x1, y0, y1):
    """Вырезает кадр, уменьшает в 2 раза и ставит на общий холст по центру/низу."""
    crop = img.crop((x0, y0, x1, y1))
    bbox = crop.getbbox()
    if bbox:
        crop = crop.crop(bbox)
    small = crop.resize((max(1, crop.width // 2), max(1, crop.height // 2)), Image.NEAREST)
    canvas = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    canvas.alpha_composite(small, ((CANVAS[0] - small.width) // 2, CANVAS[1] - small.height))
    return canvas


def main():
    img = load()
    groups = {
        "down": WALK_FRAMES[0:4],
        "side": WALK_FRAMES[4:8],
        "up": WALK_FRAMES[9:13],
    }
    for name, frames in groups.items():
        for i, (x0, x1) in enumerate(frames):
            cut(img, x0, x1, *WALK_Y).save(f"{DST}\\walk_{name}_{i}.png")
        print(name, len(frames))

    for i, (x0, x1) in enumerate(ATTACK_FRAMES[3:8]):
        cut(img, x0, x1, *ATTACK_Y).save(f"{DST}\\attack_{i}.png")
    print("attack", 5)


main()
