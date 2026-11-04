extends Node2D
class_name Arena
## Арена в стиле 3/4 на тайлах Tiny Swords (CC0, Pixel Frog, 64×64).
## Поляна — каменная платформа: по краю видно и верхнюю грань, и лицевую стену.

const TILE := 64
const TEX_GRASS := preload("res://assets/tiny-swords/tiles/grass.png")
const TEX_RIM_TOP := preload("res://assets/tiny-swords/tiles/rim_top.png")
const TEX_RIM_FACE := preload("res://assets/tiny-swords/tiles/rim_face.png")

## Сколько пикселей стены рисуем выше арены (дальняя стена).
const WALL_ABOVE := 128.0

@export var room_tiles := Vector2i(15, 9)
@export var rim_tiles := 1

var _wall_body: StaticBody2D


func size_px() -> Vector2:
	return Vector2(room_tiles.x * TILE, room_tiles.y * TILE)


## Границы камеры: включают дальнюю стену.
func camera_rect() -> Rect2:
	return Rect2(Vector2(0.0, -WALL_ABOVE), Vector2(size_px().x, size_px().y + WALL_ABOVE))


## Ходить можно внутри каменной кромки.
func playable_rect() -> Rect2:
	var pad := float(rim_tiles * TILE)
	return Rect2(Vector2(pad, pad), size_px() - Vector2(pad, pad) * 2.0)


func _ready() -> void:
	var s := size_px()
	var t := float(rim_tiles * TILE)

	_dark_backdrop(s)

	# Земля.
	_add_tiled(TEX_GRASS, Vector2.ZERO, s)

	# Дальняя стена: лицевая грань и её верхняя кромка.
	_add_tiled(TEX_RIM_FACE, Vector2(0.0, -WALL_ABOVE), Vector2(s.x, WALL_ABOVE))
	_add_tiled(TEX_RIM_TOP, Vector2(0.0, -t), Vector2(s.x, t))

	# Боковые и ближняя кромка.
	_add_tiled(TEX_RIM_TOP, Vector2(0.0, 0.0), Vector2(t, s.y))
	_add_tiled(TEX_RIM_TOP, Vector2(s.x - t, 0.0), Vector2(t, s.y))
	_add_tiled(TEX_RIM_TOP, Vector2(0.0, s.y - t), Vector2(s.x, t))

	# Боковые стенки — платформа читается объёмной.
	_add_tiled(TEX_RIM_FACE, Vector2(-t, 0.0), Vector2(t, s.y))
	_add_tiled(TEX_RIM_FACE, Vector2(s.x, 0.0), Vector2(t, s.y))

	_build_walls()


func _dark_backdrop(s: Vector2) -> void:
	var back := ColorRect.new()
	back.color = Color(0.05, 0.07, 0.08, 1.0)
	back.position = Vector2(-400.0, -WALL_ABOVE - 300.0)
	back.size = s + Vector2(800.0, 600.0 + WALL_ABOVE)
	back.z_index = -10
	add_child(back)


func _add_tiled(texture: Texture2D, at: Vector2, area: Vector2, tint: Color = Color.WHITE) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, area)
	sprite.centered = false
	sprite.position = at
	sprite.modulate = tint
	add_child(sprite)


func _build_walls() -> void:
	_wall_body = StaticBody2D.new()
	_wall_body.name = "Walls"
	add_child(_wall_body)

	var r := playable_rect()
	var rects: Array[Rect2] = [
		Rect2(0.0, 0.0, size_px().x, r.position.y),
		Rect2(0.0, r.end.y, size_px().x, size_px().y - r.end.y),
		Rect2(0.0, r.position.y, r.position.x, r.size.y),
		Rect2(r.end.x, r.position.y, size_px().x - r.end.x, r.size.y),
	]

	for rect in rects:
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			continue
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		var cs := CollisionShape2D.new()
		cs.shape = shape
		cs.position = rect.position + rect.size * 0.5
		_wall_body.add_child(cs)
