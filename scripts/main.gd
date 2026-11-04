extends Node2D
## Корневая сцена: собирает арену, героя и заглушки окружения,
## раздаёт границы камеры и умеет делать скриншоты для проверки (--shot).

const PROP_TREE := Vector2i(96, 128)
const PROP_TREE_SMALL := Vector2i(64, 96)
const PROP_ROCK := Vector2i(32, 32)

const COLOR_TREE := Color("28402f")
const COLOR_TREE_SMALL := Color("314c38")
const COLOR_ROCK := Color("4a4f58")

var _arena: Arena
var _player: Player


func _ready() -> void:
	_arena = $World/Arena
	_player = $World/Player

	_player.set_bounds(_arena.playable_rect(), Rect2(Vector2.ZERO, _arena.size_px()))
	_spawn_props()
	_maybe_capture()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _spawn_props() -> void:
	# Два дерева на одной вертикали с героем — сразу видно, как работает Y-sort:
	# верхнее перекрывается героем, нижнее перекрывает его.
	_add_prop(Vector2(640.0, 330.0), PROP_TREE, COLOR_TREE)
	_add_prop(Vector2(672.0, 428.0), PROP_TREE_SMALL, COLOR_TREE_SMALL)
	_add_prop(Vector2(470.0, 300.0), PROP_ROCK, COLOR_ROCK)
	_add_prop(Vector2(830.0, 470.0), PROP_ROCK, COLOR_ROCK)


func _add_prop(at: Vector2, size: Vector2i, color: Color) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = _solid_texture(size, color)
	sprite.position = at
	# Точка опоры — нижняя кромка, иначе Y-sort будет врать.
	sprite.offset = Vector2(0.0, -float(size.y) * 0.5)
	$World.add_child(sprite)


func _solid_texture(size: Vector2i, color: Color) -> ImageTexture:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


func _maybe_capture() -> void:
	var args := OS.get_cmdline_args() + OS.get_cmdline_user_args()
	if not args.has("--shot"):
		return

	await get_tree().create_timer(0.5).timeout
	_save_shot("res://shot.png")

	# Второй кадр — у стены: проверяем границы комнаты и камеры.
	var corner := _arena.playable_rect().position + Vector2(60.0, 70.0)
	_player.global_position = corner
	_player.camera.reset_smoothing()
	await get_tree().process_frame
	await get_tree().process_frame
	_save_shot("res://shot_corner.png")

	get_tree().quit()


func _save_shot(res_path: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path(res_path)
	img.save_png(path)
	print("SHOT_SAVED ", path)
