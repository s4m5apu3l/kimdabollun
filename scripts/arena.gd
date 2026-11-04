extends Node2D
class_name Arena
## Первая сцена: поляна в тайге.
## Пол и лес по краю — тайлы Kenney (Roguelike/RPG pack, CC0, 16×16),
## выложенные через тайлящийся Sprite2D: без швов и без TileSet.

const TILE := 16
const TEX_GRASS := preload("res://assets/sprites/grass.png")
const TEX_PINE := preload("res://assets/sprites/forest.png")

@export var room_tiles := Vector2i(34, 18)
@export var treeline_tiles := 2

var _wall_body: StaticBody2D


func size_px() -> Vector2:
	return Vector2(room_tiles.x * TILE, room_tiles.y * TILE)


## Зона, по которой можно ходить: всё, кроме полосы леса по краю.
func playable_rect() -> Rect2:
	var pad := float(treeline_tiles * TILE)
	return Rect2(Vector2(pad, pad), size_px() - Vector2(pad, pad) * 2.0)


func _ready() -> void:
	var s := size_px()
	var t := float(treeline_tiles * TILE)

	_add_tiled(TEX_GRASS, Vector2.ZERO, s)
	_add_tiled(TEX_PINE, Vector2(0.0, 0.0), Vector2(s.x, t))
	_add_tiled(TEX_PINE, Vector2(0.0, s.y - t), Vector2(s.x, t))
	_add_tiled(TEX_PINE, Vector2(0.0, t), Vector2(t, s.y - t * 2.0))
	_add_tiled(TEX_PINE, Vector2(s.x - t, t), Vector2(t, s.y - t * 2.0))

	_build_walls()


func _add_tiled(texture: Texture2D, at: Vector2, area: Vector2) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, area)
	sprite.centered = false
	sprite.position = at
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
