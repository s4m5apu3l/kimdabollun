extends Node2D
class_name Arena
## Боевая комната: пол-шахматка, стены по краю, границы для камеры.
## Пока заглушки рисуются кодом; позже заменим на TileMapLayer + TileSet.

const TILE := 32

const FLOOR_A := Color("2b303a")
const FLOOR_B := Color("353b46")
const WALL_FACE := Color("1b1f26")
const WALL_TOP := Color("2e3641")
const WALL_EDGE := Color("4a5567")

@export var room_tiles := Vector2i(40, 24)
@export var wall_tiles := 1

var _wall_body: StaticBody2D


func size_px() -> Vector2:
	return Vector2(room_tiles.x * TILE, room_tiles.y * TILE)


## Прямоугольник, внутри которого можно ходить и за который не выезжает камера.
func playable_rect() -> Rect2:
	var pad := float(wall_tiles * TILE)
	return Rect2(Vector2(pad, pad), size_px() - Vector2(pad, pad) * 2.0)


func _ready() -> void:
	_build_walls()
	queue_redraw()


func _build_walls() -> void:
	_wall_body = StaticBody2D.new()
	_wall_body.name = "Walls"
	add_child(_wall_body)

	var s := size_px()
	var t := float(wall_tiles * TILE)
	var rects: Array[Rect2] = [
		Rect2(0.0, 0.0, s.x, t),
		Rect2(0.0, s.y - t, s.x, t),
		Rect2(0.0, t, t, s.y - t * 2.0),
		Rect2(s.x - t, t, t, s.y - t * 2.0),
	]

	for r in rects:
		if r.size.x <= 0.0 or r.size.y <= 0.0:
			continue
		var shape := RectangleShape2D.new()
		shape.size = r.size
		var cs := CollisionShape2D.new()
		cs.shape = shape
		cs.position = r.position + r.size * 0.5
		_wall_body.add_child(cs)


func _draw() -> void:
	# Пол.
	for y in room_tiles.y:
		for x in room_tiles.x:
			var c := FLOOR_A if (x + y) % 2 == 0 else FLOOR_B
			draw_rect(Rect2(x * TILE, y * TILE, TILE, TILE), c)

	# Стены-кольцо.
	for y in room_tiles.y:
		for x in room_tiles.x:
			var is_inner := (
				x >= wall_tiles
				and y >= wall_tiles
				and x < room_tiles.x - wall_tiles
				and y < room_tiles.y - wall_tiles
			)
			if is_inner:
				continue
			var color := WALL_TOP if y < wall_tiles else WALL_FACE
			draw_rect(Rect2(x * TILE, y * TILE, TILE, TILE), color)

	# Светлая кромка под верхней стеной — читается граница проходимой зоны.
	var t := float(wall_tiles * TILE)
	var s := size_px()
	draw_rect(Rect2(0.0, t - 4.0, s.x, 4.0), WALL_EDGE)
	draw_rect(Rect2(0.0, s.y - t, s.x, 4.0), WALL_EDGE.darkened(0.35))
