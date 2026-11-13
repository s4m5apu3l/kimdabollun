extends Node2D
## Корневая сцена: собирает арену, героя и декор,
## раздаёт границы камеры и умеет делать скриншоты для проверки (--shot).

const SPRITE_SHADOW := preload("res://assets/sprites/shadow_blob.png")

## Декор: [путь, позиция ступней].
const DECO := [
	["res://assets/new/tree_a.png", Vector2(180.0, 200.0)],
	["res://assets/new/tree_b.png", Vector2(300.0, 430.0)],
	["res://assets/new/tree_c.png", Vector2(800.0, 190.0)],
	["res://assets/new/tree_d.png", Vector2(720.0, 420.0)],
	["res://assets/new/stone.png", Vector2(600.0, 300.0)],
	["res://assets/new/stone.png", Vector2(360.0, 160.0)],
	["res://assets/new/bonfire.png", Vector2(480.0, 400.0)],
]

## Кострище стоит здесь, над ним играет огонь.
const FLAME_AT := Vector2(480.0, 356.0)

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
		_add_prop(load(String(item[0])), item[1])
	_add_flame()


func _add_flame() -> void:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("fire")
	frames.set_animation_speed("fire", 8.0)
	frames.set_animation_loop("fire", true)
	for i in 5:
		frames.add_frame("fire", load("res://assets/new/flame_%03d.png" % i))

	var flame := AnimatedSprite2D.new()
	flame.sprite_frames = frames
	flame.position = FLAME_AT
	flame.play("fire")
	$World.add_child(flame)


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

	# Атака вправо: проверяем, что кадры выпада действительно вправо.
	Input.action_press("move_right")
	await get_tree().create_timer(0.2).timeout
	Input.action_release("move_right")
	Input.action_press("attack")
	await get_tree().create_timer(0.25).timeout
	_save_shot("res://shot_attack.png")
	Input.action_release("attack")

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
