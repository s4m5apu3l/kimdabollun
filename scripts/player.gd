extends CharacterBody2D
class_name Player
## Герой. Точка origin — по центру ступней, чтобы Y-sort работал корректно.
## Спрайт-заглушка 64×96 рисуется от ступней вверх, коллизия — узкая, 32×20.

const SPEED := 220.0
const ACCEL := 1800.0
const FRICTION := 2600.0

const BODY_SIZE := Vector2(64.0, 96.0)
const COLOR_BODY := Color("cfdae6")
const COLOR_COAT := Color("57708c")
const COLOR_ACCENT := Color("f0c25a")

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
	queue_redraw()


func _clamp_to_arena() -> void:
	if _bounds.size == Vector2.ZERO:
		return
	global_position = global_position.clamp(_bounds.position, _bounds.end)


func _draw() -> void:
	# Тень под ногами.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2(0.0, -4.0), 22.0, Color(0.0, 0.0, 0.0, 0.30))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var half_w := BODY_SIZE.x * 0.5
	var top := -BODY_SIZE.y

	# Плащ от плеч до земли.
	draw_rect(Rect2(-half_w, top + 28.0, BODY_SIZE.x, BODY_SIZE.y - 28.0), COLOR_COAT)
	# Плечи.
	draw_rect(Rect2(-half_w + 6.0, top + 22.0, BODY_SIZE.x - 12.0, 10.0), COLOR_BODY)
	# Голова и капюшон.
	draw_rect(Rect2(-15.0, top + 4.0, 30.0, 26.0), COLOR_BODY)
	draw_rect(Rect2(-11.0, top + 10.0, 22.0, 12.0), COLOR_COAT.lightened(0.12))
	# Указатель направления взгляда.
	draw_circle(facing * 16.0 + Vector2(0.0, top + 20.0), 4.0, COLOR_ACCENT)
