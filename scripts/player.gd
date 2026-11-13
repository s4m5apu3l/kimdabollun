extends CharacterBody2D
class_name Player
## Герой-крестьянин. Четыре направления: юг, восток, север, запад (запад = отражение).
## Origin по центру ступней: ячейка 152×104, ступни на y=81.

const SPEED := 165.0
const ACCEL := 1400.0
const FRICTION := 2000.0

const FRAME_DIR := "res://assets/sprites/hero/"
const FRAMES := 9
const RUN_FPS := 12.0
const ATK_FPS := 16.0

const CELL_W := 152.0
const CELL_H := 104.0
const FEET_Y := 81.0

const DIRS := ["s", "e", "n", "w"]

var facing := Vector2.DOWN
var direction := "s"

var _bounds := Rect2()
var _current := ""
var _attack_time := 0.0

@onready var hero: AnimatedSprite2D = $Hero
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	hero.sprite_frames = _build_frames()
	hero.centered = false
	hero.offset = Vector2(-CELL_W * 0.5, -FEET_Y)
	_play("idle_s")


func _build_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	for code in DIRS:
		var source: String = "e" if code == "w" else code

		var idle: String = "idle_" + code
		frames.add_animation(idle)
		frames.set_animation_speed(idle, 1.0)
		frames.set_animation_loop(idle, false)
		frames.add_frame(idle, load(FRAME_DIR + "idle_%s.png" % source))

		var run: String = "run_" + code
		frames.add_animation(run)
		frames.set_animation_speed(run, RUN_FPS)
		frames.set_animation_loop(run, true)
		for i in FRAMES:
			frames.add_frame(run, load(FRAME_DIR + "run_%s_%d.png" % [source, i]))

		var atk: String = "atk_" + code
		frames.add_animation(atk)
		frames.set_animation_speed(atk, ATK_FPS)
		frames.set_animation_loop(atk, false)
		for i in FRAMES:
			frames.add_frame(atk, load(FRAME_DIR + "atk_%s_%d.png" % [source, i]))

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

	if _attack_time > 0.0:
		_attack_time -= delta

	if input_dir != Vector2.ZERO:
		facing = input_dir.normalized()
		direction = _dir_code(facing)

	if _attack_time > 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * 2.0 * delta)
	else:
		if Input.is_action_just_pressed("attack"):
			_start_attack()
		if input_dir == Vector2.ZERO:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		else:
			velocity = velocity.move_toward(input_dir * SPEED, ACCEL * delta)

	move_and_slide()
	_clamp_to_arena()

	if _attack_time > 0.0:
		return
	_play(("run_" if input_dir != Vector2.ZERO else "idle_") + direction)


func _start_attack() -> void:
	_attack_time = float(FRAMES) / ATK_FPS
	_play("atk_" + direction)


func _dir_code(v: Vector2) -> String:
	if absf(v.x) >= absf(v.y):
		return "e" if v.x >= 0.0 else "w"
	return "s" if v.y >= 0.0 else "n"


func _play(animation: String) -> void:
	var flip := animation.ends_with("_w")
	if _current == animation:
		hero.flip_h = flip
		return
	_current = animation
	hero.flip_h = flip
	hero.play(animation)


func _clamp_to_arena() -> void:
	if _bounds.size == Vector2.ZERO:
		return
	global_position = global_position.clamp(_bounds.position, _bounds.end)


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.38))
	draw_circle(Vector2(0.0, -2.0), 16.0, Color(0.0, 0.0, 0.0, 0.30))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
