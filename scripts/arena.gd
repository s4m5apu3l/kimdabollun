extends Node2D
class_name Arena
## Первая сцена: поляна в тайге.
## Фон — сплошной тёмный лес, поверх — трава поляны, по краю стоят отдельные ели.
## Так камера никогда не показывает пустоту, а лес читается как стена вокруг поляны.

const TILE := 32
const TEX_GRASS := preload("res://assets/sprites/grass.png")
const TEX_FOREST := preload("res://assets/sprites/forest.png")

## Насколько фон-лес больше поляны (рисуется с запасом во все стороны).
const FOREST_MARGIN := 256

@export var room_tiles := Vector2i(30, 17)
@export var treeline_tiles := 1

var _wall_body: StaticBody2D


func size_px() -> Vector2:
	return Vector2(room_tiles.x * TILE, room_tiles.y * TILE)


## Границы камеры — ровно поляна.
func camera_rect() -> Rect2:
	return Rect2(Vector2.ZERO, size_px())


## Зона, по которой можно ходить: всё, кроме полосы деревьев по краю.
func playable_rect() -> Rect2:
	var pad := float(treeline_tiles * TILE)
	return Rect2(Vector2(pad, pad), size_px() - Vector2(pad, pad) * 2.0)


func _ready() -> void:
	var s := size_px()

	# Сплошной лес за пределами поляны.
	_add_tiled(
		TEX_FOREST,
		Vector2(-FOREST_MARGIN, -FOREST_MARGIN),
		s + Vector2(FOREST_MARGIN, FOREST_MARGIN) * 2.0
	)
	# Сама поляна.
	_add_tiled(TEX_GRASS, Vector2.ZERO, s)

	_build_walls()


func _add_tiled(texture: Texture2D, at: Vector2, area: Vector2) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, area)
	sprite.centered = false
	sprite.position = at
	sprite.modulate = Color(0.42, 0.48, 0.56, 1.0) if area.x > 400.0 else Color.WHITE
	add_child(sprite)


func _build_walls() -> void:
	_wall_body = StaticBody2D.new()
	_wall_body.name = "Walls"
	add_child(_wall_body)

	var s := size_px()
	var t := float(treeline_tiles * TILE)
	var rects: Array[Rect2] = [
		Rect2(0.0, 0.0, s.x, t),
		Rect2(0.0, s.y - t, s.x, t),
		Rect2(0.0, t, t, s.y - t * 2.0),
		Rect2(s.x - t, t, t, s.y - t * 2.0),
	]

	for r in rects:
		var shape := RectangleShape2D.new()
		shape.size = r.size
		var cs := CollisionShape2D.new()
		cs.shape = shape
		cs.position = r.position + r.size * 0.5
		_wall_body.add_child(cs)
