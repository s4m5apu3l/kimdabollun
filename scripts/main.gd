extends Node2D
## Корневая сцена: собирает поляну, героя и декор,
## раздаёт границы камеры и умеет делать скриншоты для проверки (--shot).

const SPRITE_PINE := preload("res://assets/sprites/tree_big_cold.png")
const SPRITE_CHEST := preload("res://assets/sprites/chest.png")
const SPRITE_TREE := preload("res://assets/sprites/tree_big.png")

## Затемнение леса по краю: центр поляны должен читаться как освещённый.
const NIGHT := Color(0.42, 0.48, 0.56, 1.0)

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
	# Отдельные деревья внутри поляны: с героем они делят Y-sort,
	# поэтому получается честное перекрытие по глубине.
	# Верхний край — стена леса отдельными высокими елями.
	# Они в том же Y-sorted узле, что и герой, поэтому он честно уходит за них.
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var size := _arena.size_px()

	# Верхний и нижний край.
	var x := -12.0
	while x < size.x + 12.0:
		_add_sprite(_pick_tree(rng), Vector2(x + rng.randf_range(-4.0, 4.0), rng.randf_range(10.0, 18.0)), NIGHT)
		_add_sprite(_pick_tree(rng), Vector2(x + rng.randf_range(-6.0, 6.0), size.y + rng.randf_range(-8.0, 2.0)), NIGHT)
		x += rng.randf_range(16.0, 26.0)

	# Боковые края.
	var y := 18.0
	while y < size.y - 10.0:
		_add_sprite(_pick_tree(rng), Vector2(rng.randf_range(6.0, 15.0), y), NIGHT)
		_add_sprite(_pick_tree(rng), Vector2(size.x - rng.randf_range(6.0, 15.0), y), NIGHT)
		y += rng.randf_range(16.0, 24.0)

	# Пара елей внутри поляны — для глубины сцены.
	_add_sprite(SPRITE_TREE, Vector2(62.0, 118.0))
	_add_sprite(SPRITE_PINE, Vector2(318.0, 132.0))
	_add_sprite(SPRITE_CHEST, Vector2(206.0, 96.0))


func _pick_tree(rng: RandomNumberGenerator) -> Texture2D:
	return SPRITE_TREE if rng.randi() % 2 == 0 else SPRITE_PINE


func _add_sprite(texture: Texture2D, at: Vector2, tint: Color = Color.WHITE) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = at
	# Точка опоры — нижняя кромка спрайта.
	sprite.offset = Vector2(0.0, -float(texture.get_height()) * 0.5)
	sprite.modulate = tint
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
