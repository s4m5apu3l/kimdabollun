extends CharacterBody2D
class_name Player
## Герой из атласа Pixel_art_character_chib (8 направлений: стойка + бег).
## Origin — по центру ступней: ячейка 96×96 поднята на половину высоты.

const SPEED := 165.0
const ACCEL := 1400.0
const FRICTION := 2000.0

const FRAME_DIR := "res://assets/sprites/hero/"
const RUN_FRAMES := 6
const RUN_FPS := 12.0
const CELL := 96.0

## 8 направлений: код кадра и вектор.
const DIRS := [
	{"code": "e", "v": Vector2(1.0, 0.0)},
	{"code": "se", "v": Vector2(1.0, 1.0)},
	{"code": "s", "v": Vector2(0.0, 1.0)},
	{"code": "sw", "v": Vector2(-1.0, 1.0)},
	{"code": "w", "v": Vector2(-1.0, 0.0)},
	{"code": "nw", "v": Vector2(-1.0, -1.0)},
	{"code": "n", "v": Vector2(0.0, -1.0)},
	{"code": "ne", "v": Vector2(1.0, -1.0)},
]

var facing := Vector2.DOWN
var direction := "s"

var _bounds := Rect2()
var _current := ""

@onready var hero: AnimatedSprite2D = $Hero
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	hero.sprite_frames = _build_frames()
	hero.offset = Vector2(0.0, -CELL * 0.5)
	_play("idle_" + direction)


func _build_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	for d in DIRS:
		var code: String = d["code"]

		var idle: String = "idle_" + code
		frames.add_animation(idle)
		frames.set_animation_speed(idle, 1.0)
		frames.set_animation_loop(idle, false)
		frames.add_frame(idle, load(FRAME_DIR + "idle_%s.png" % code))

		var run: String = "run_" + code
		frames.add_animation(run)
		frames.set_animation_speed(run, RUN_FPS)
		frames.set_animation_loop(run, true)
		for i in RUN_FRAMES:
			frames.add_frame(run, load(FRAME_DIR + "run_%s_%d.png" % [code, i]))

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
		direction = _dir_code(input_dir)

	move_and_slide()
	_clamp_to_arena()
	_play(("run_" if input_dir != Vector2.ZERO else "idle_") + direction)


func _dir_code(v: Vector2) -> String:
	var best := "s"
	var best_dot := -2.0
	var n := v.normalized()
	for d in DIRS:
		var dot: float = n.dot((d["v"] as Vector2).normalized())
		if dot > best_dot:
			best_dot = dot
			best = d["code"]
	return best


func _play(animation: String) -> void:
	if _current == animation:
		return
	_current = animation
	hero.play(animation)


func _clamp_to_arena() -> void:
	if _bounds.size == Vector2.ZERO:
		return
	global_position = global_position.clamp(_bounds.position, _bounds.end)
