extends CharacterBody2D
class_name Player
## Герой. Origin — по центру ступней, спрайт 16×16 поднят на 8 px вверх.

const SPEED := 90.0
const ACCEL := 900.0
const FRICTION := 1200.0

var facing := Vector2.DOWN

var _bounds := Rect2()

@onready var camera: Camera2D = $Camera2D


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


func _clamp_to_arena() -> void:
	if _bounds.size == Vector2.ZERO:
		return
	global_position = global_position.clamp(_bounds.position, _bounds.end)


func _draw() -> void:
	# Мягкая тень под ногами, чтобы герой не «висел» над землёй.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0.0, -1.0), 6.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
