extends CharacterBody2D
## Точный платформер-контроллер — фундамент game feel (Super Meat Boy) и база под
## метроидванию (Hollow Knight). ВСЁ настраивается в инспекторе: крути числа,
## пока управление не станет «вкусным». Это самая важная часть игры на старте.

@export_group("Бег")
@export var max_speed := 240.0
@export var accel := 2200.0
@export var friction := 2600.0
@export var air_accel := 1600.0

@export_group("Прыжок")
@export var jump_velocity := -520.0
@export var gravity := 1600.0
@export var fall_gravity := 2200.0          ## Падаем быстрее, чем взлетаем — даёт «вес»
@export var max_fall := 950.0
@export var coyote_time := 0.10             ## Можно прыгнуть чуть-чуть после схода с края
@export var jump_buffer := 0.10             ## Прыжок засчитается, если нажал за миг до земли
@export var jump_cut := 0.45                ## Отпустил рано — прыжок короче (variable jump)

@export_group("Стены")
@export var wall_slide_speed := 130.0
@export var wall_jump_push := 340.0
@export var wall_jump_velocity := -500.0
@export var wall_jump_lock := 0.12          ## Короткая блокировка управления после отскока

@export_group("Рывок (dash)")
@export var dash_speed := 640.0
@export var dash_time := 0.14
@export var dash_cooldown := 0.30

var _coyote := 0.0
var _buffer := 0.0
var _jump_held := false
var _wall_lock := 0.0
var _facing := 1.0
var _dashing := false
var _dash_t := 0.0
var _dash_cd := 0.0
var _dash_dir := Vector2.ZERO
var _can_dash := true
var _start_pos := Vector2.ZERO

func _ready() -> void:
	_start_pos = global_position

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("restart") or global_position.y > _start_pos.y + 1500.0:
		_respawn()
		return

	var input_x := Input.get_axis("move_left", "move_right")
	if input_x != 0.0:
		_facing = signf(input_x)

	_coyote = maxf(_coyote - delta, 0.0)
	_buffer = maxf(_buffer - delta, 0.0)
	_wall_lock = maxf(_wall_lock - delta, 0.0)
	_dash_cd = maxf(_dash_cd - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_buffer = jump_buffer
		_jump_held = true
	if Input.is_action_just_released("jump"):
		_jump_held = false
		if velocity.y < 0.0:
			velocity.y *= jump_cut

	# --- Рывок: приоритетнее всего, на время рывка обычная физика отключается ---
	if Input.is_action_just_pressed("dash") and _can_dash and _dash_cd <= 0.0:
		_start_dash()
	if _dashing:
		_dash_t -= delta
		velocity = _dash_dir * dash_speed
		if _dash_t <= 0.0:
			_dashing = false
			velocity *= 0.4
		move_and_slide()
		return

	if is_on_floor():
		_coyote = coyote_time
		_can_dash = true

	# --- Горизонталь (с блокировкой после отскока от стены) ---
	if _wall_lock <= 0.0:
		if input_x != 0.0:
			var a := accel if is_on_floor() else air_accel
			velocity.x = move_toward(velocity.x, input_x * max_speed, a * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# --- Гравитация + скольжение по стене ---
	var sliding := is_on_wall_only() and input_x != 0.0 and velocity.y > 0.0
	if not is_on_floor():
		var g := fall_gravity if velocity.y > 0.0 else gravity
		velocity.y = minf(velocity.y + g * delta, max_fall)
		if sliding:
			velocity.y = minf(velocity.y, wall_slide_speed)
	if is_on_wall_only():
		_can_dash = true

	# --- Прыжок / прыжок от стены (учитывает coyote и buffer) ---
	if _buffer > 0.0:
		if _coyote > 0.0:
			velocity.y = jump_velocity
			_buffer = 0.0
			_coyote = 0.0
		elif is_on_wall_only():
			var n := get_wall_normal()
			velocity.x = n.x * wall_jump_push
			velocity.y = wall_jump_velocity
			_wall_lock = wall_jump_lock
			_buffer = 0.0
			_can_dash = true

	move_and_slide()

func _start_dash() -> void:
	# 8-направленный рывок по текущему вводу; если ввода нет — рывок «вперёд».
	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if dir == Vector2.ZERO:
		dir = Vector2(_facing, 0.0)
	_dash_dir = dir.normalized()
	_dashing = true
	_dash_t = dash_time
	_dash_cd = dash_cooldown
	_can_dash = false

func _respawn() -> void:
	velocity = Vector2.ZERO
	global_position = _start_pos
	_dashing = false
	_can_dash = true
