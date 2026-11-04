extends Node2D
## Корневая сцена: собирает арену, героя и декор,
## раздаёт границы камеры и умеет делать скриншоты для проверки (--shot).

const SPRITE_SHADOW := preload("res://assets/sprites/shadow_blob.png")

## Декор из Tiny Swords: [файл, позиция ступней].
const DECO := [
	["deco_18.png", Vector2(300.0, 240.0)],
	["deco_16.png", Vector2(760.0, 210.0)],
	["deco_17.png", Vector2(700.0, 430.0)],
	["deco_09.png", Vector2(170.0, 430.0)],
]

var _arena: Arena
var _player: Player


func _ready() -> void:
	_arena = $World/Arena
	_player = $World/Player

	_player.set_bounds(_arena.playable_rect(), _arena.camera_rect())
	_spawn_decor()
	_maybe_capture()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _spawn_decor() -> void:
	for item in DECO:
		var path: String = "res://assets/tiny-swords/deco/" + String(item[0])
		_add_prop(load(path), item[1])


func _add_prop(texture: Texture2D, at: Vector2) -> void:
	# Контактная тень, затем сам объект: объект «стоит» на земле.
	var shadow := Sprite2D.new()
	shadow.texture = SPRITE_SHADOW
	shadow.position = at
	shadow.offset = Vector2(0.0, -6.0)
	shadow.scale = Vector2(maxf(0.5, float(texture.get_width()) / 64.0), 1.0)
	$World.add_child(shadow)

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = at
	sprite.offset = Vector2(0.0, -float(texture.get_height()) * 0.5)
	$World.add_child(sprite)


func _maybe_capture() -> void:
	var args := OS.get_cmdline_args() + OS.get_cmdline_user_args()
	if not args.has("--shot"):
		return

	await get_tree().create_timer(0.5).timeout
	_save_shot("res://shot.png")

	Input.action_press("move_right")
	await get_tree().create_timer(0.6).timeout
	_save_shot("res://shot_walk.png")
	Input.action_release("move_right")

	var corner := _arena.playable_rect().position + Vector2(40.0, 40.0)
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
