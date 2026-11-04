extends CharacterBody2D
class_name Player
## Герой. Кадры нарезаны из атласа (tools/hero_frames.py) и уменьшены вдвое.
## Origin — по центру ступней: спрайт поднят на половину высоты.

const SPEED := 165.0
const ACCEL := 1400.0
const FRICTION := 2000.0

const FRAME_DIR := "res://assets/sprites/hero/"
const FRAME_COUNT := 4
const WALK_FPS := 9.0

const DIRECTIONS := ["down", "up", "side"]

var facing := Vector2.DOWN

var _bounds := Rect2()
var _current := ""

@onready var hero: AnimatedSprite2D = $Hero
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	hero.sprite_frames = _build_frames()
	hero.offset = Vector2(0.0, -float(hero.sprite_frames.get_frame_texture("idle_down", 0).get_height()) * 0.5)
	_play("idle_down")


func _build_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	for dir in DIRECTIONS:
		var walk: String = "walk_" + dir
		frames.add_animation(walk)
		frames.set_animation_speed(walk, WALK_FPS)
		frames.set_animation_loop(walk, true)
		for i in FRAME_COUNT:
			frames.add_frame(walk, load(FRAME_DIR + "walk_%s_%d.png" % [dir, i]))

		var idle: String = "idle_" + dir
		frames.add_animation(idle)
		frames.set_animation_speed(idle, 1.0)
		frames.set_animation_loop(idle, false)
		frames.add_frame(idle, load(FRAME_DIR + "walk_%s_0.png" % dir))

	return frames


func set_bounds(walk_rect: Rect2, camera_rect: Rect2 = Rect2()) -> void:
	_bounds = walk_rect
	var view := camera_rect if camera_rect.size != Vector2.ZERO else walk_rect
	camera.limit_left = int(view.position.x)
	camera.limit_top = int(view.position.y)
	camera.limit_right = int(view.end.x)
	camera.limit_bottom = int(view.end.y)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_dir == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = velocity.move_toward(input_dir * SPEED, ACCEL * delta)
		facing = input_dir.normalized()

	move_and_slide()
	_clamp_to_arena()
	_update_animation(input_dir)


func _update_animation(input_dir: Vector2) -> void:
	var moving := input_dir != Vector2.ZERO
	var dir := "side"
	if moving:
		if absf(input_dir.y) >= absf(input_dir.x):
			dir = "down" if input_dir.y > 0.0 else "up"
		else:
			dir = "side"
	elif _current != "":
		dir = _current.get_slice("_", 1)

	hero.flip_h = dir == "side" and facing.x < 0.0
	_play(("walk_" if moving else "idle_") + dir)


func _play(animation: String) -> void:
	if _current == animation:
		return
	_current = animation
	hero.play(animation)


func _clamp_to_arena() -> void:
	if _bounds.size == Vector2.ZERO:
		return
	global_position = global_position.clamp(_bounds.position, _bounds.end)


func _draw() -> void:
	# Мягкая тень под ногами.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2(0.0, -2.0), 12.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
