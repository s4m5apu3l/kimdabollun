extends Node2D
## Корневая сцена: собирает поляну, героя и декор,
## раздаёт границы камеры и умеет делать скриншоты для проверки (--shot).

const SPRITE_PINE := preload("res://assets/sprites/pine_cold.png")
const SPRITE_CHEST := preload("res://assets/sprites/chest.png")

var _arena: Arena
var _player: Player


func _ready() -> void:
	_arena = $World/Arena
	_player = $World/Player

	_player.set_bounds(_arena.playable_rect(), Rect2(Vector2.ZERO, _arena.size_px()))
	_spawn_decor()
	_maybe_capture()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _spawn_decor() -> void:
	# Отдельные деревья внутри поляны: с героем они делят Y-sort,
	# поэтому получается честное перекрытие по глубине.
	_add_sprite(SPRITE_PINE, Vector2(120.0, 100.0))
	_add_sprite(SPRITE_PINE, Vector2(250.0, 85.0))
	_add_sprite(SPRITE_PINE, Vector2(410.0, 105.0))
	_add_sprite(SPRITE_PINE, Vector2(175.0, 205.0))
	_add_sprite(SPRITE_PINE, Vector2(430.0, 215.0))
	_add_sprite(SPRITE_CHEST, Vector2(300.0, 158.0))


func _add_sprite(texture: Texture2D, at: Vector2) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = at
	# Точка опоры — нижняя кромка спрайта.
	sprite.offset = Vector2(0.0, -float(texture.get_height()) * 0.5)
	$World.add_child(sprite)


func _maybe_capture() -> void:
	var args := OS.get_cmdline_args() + OS.get_cmdline_user_args()
	if not args.has("--shot"):
		return

	await get_tree().create_timer(0.5).timeout
	_save_shot("res://shot.png")

	# Второй кадр — у края поляны: видно лес и границу камеры.
	var corner := _arena.playable_rect().position + Vector2(30.0, 40.0)
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
