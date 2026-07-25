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
@export var max_air_jumps := 1              ## Сколько прыжков в воздухе даёт двойной прыжок

@export_group("Стены")
@export var wall_slide_speed := 130.0
@export var wall_jump_push := 340.0
@export var wall_jump_velocity := -500.0
@export var wall_jump_lock := 0.12          ## Короткая блокировка управления после отскока

@export_group("Рывок (dash)")
@export var dash_speed := 640.0
@export var dash_time := 0.14
@export var dash_cooldown := 0.30

@export_group("Juice (game feel)")
@export var jump_shake := 2.0
@export var walljump_shake := 2.5
@export var land_shake := 3.0
@export var dash_shake := 4.0
@export var death_shake := 9.0
@export var shake_decay := 30.0             ## Как быстро гаснет тряска
@export var land_threshold := 320.0         ## Мин. скорость падения для «удара» о землю
@export var death_hitstop := 0.07           ## Стоп-кадр в момент смерти (сек, реального времени)

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
var _checkpoint := Vector2.ZERO             ## Куда возрождаемся (последний зажжённый уголёк)
var _shake := 0.0                           ## Текущая амплитуда тряски камеры
var _dead := false                          ## На время смерти-стоп-кадра глушим управление
var _was_on_floor := false                  ## Для детекта момента приземления
var _has_double_jump := false               ## Способность-гейт: разблокируется пикапом
var _air_jumps := 0                          ## Осталось прыжков в воздухе

@onready var _cam: Camera2D = $Camera2D

func _ready() -> void:
	_start_pos = global_position
	_checkpoint = global_position
	add_to_group("player")                  ## чтобы шипы/чекпоинты находили нас

func _physics_process(delta: float) -> void:
	if _dead:
		return
	if Input.is_action_just_pressed("restart") or global_position.y > _start_pos.y + 1500.0:
		die()
		return

	_update_shake(delta)

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
		_was_on_floor = is_on_floor()
		return

	if is_on_floor():
		_coyote = coyote_time
		_can_dash = true
		_air_jumps = max_air_jumps           # перезарядка воздушных прыжков на земле

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
			Sfx.play("jump")
			_add_shake(jump_shake)
			Fx.dust(global_position + Vector2(0, 20), Palette.CH1_FOG, 6)
		elif is_on_wall_only():
			var n := get_wall_normal()
			velocity.x = n.x * wall_jump_push
			velocity.y = wall_jump_velocity
			_wall_lock = wall_jump_lock
			_buffer = 0.0
			_can_dash = true
			_air_jumps = max_air_jumps        # отскок от стены тоже перезаряжает
			Sfx.play("walljump")
			_add_shake(walljump_shake)
			Fx.dust(global_position + Vector2(-n.x * 12, 0), Palette.CH1_FOG, 6)
		elif _has_double_jump and _air_jumps > 0:
			# --- Двойной прыжок (способность-гейт) ---
			velocity.y = jump_velocity * 0.9
			_air_jumps -= 1
			_buffer = 0.0
			Sfx.play("jump", 1.1)
			_add_shake(jump_shake)
			Fx.burst(global_position, Palette.AMBER_CORE, 10, 120.0, 0.4, "glow")

	# --- Приземление: удар о землю после заметного падения = звук, пыль, тряска ---
	var fall_speed := velocity.y
	move_and_slide()
	if is_on_floor() and not _was_on_floor and fall_speed > land_threshold:
		Sfx.play("land", 0.9 + fall_speed / 4000.0)          # чем сильнее удар — тем ниже тон
		_add_shake(land_shake * clampf(fall_speed / max_fall, 0.4, 1.0))
		Fx.dust(global_position + Vector2(0, 20), Palette.CH1_FOG)
	_was_on_floor = is_on_floor()

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
	Sfx.play("dash")
	_add_shake(dash_shake)
	Fx.burst(global_position, Palette.AMBER_CORE, 12, 150.0, 0.4)   # янтарный шлейф

## Смерть = juice + мгновенный возврат на последний чекпоинт. Зовут шипы/падение/R.
## Порядок: звук + вспышка искр + тряска → стоп-кадр → перенос на чекпоинт.
func die() -> void:
	if _dead:
		return
	_dead = true
	velocity = Vector2.ZERO
	Sfx.play("death")
	_add_shake(death_shake)
	Fx.burst(global_position, Palette.AMBER_LIGHT, 22, 260.0, 0.6, "glow")   # жизнь-уголёк разлетается

	await _hitstop(death_hitstop)

	global_position = _checkpoint
	_dashing = false
	_dash_cd = 0.0
	_can_dash = true
	_coyote = 0.0
	_buffer = 0.0
	_wall_lock = 0.0
	_was_on_floor = false
	_dead = false

## Зажечь новый уголёк: сюда будем возрождаться. Зовёт чекпоинт при касании.
func set_checkpoint(pos: Vector2) -> void:
	_checkpoint = pos

## Отскок после стомпа врага (прыжок сверху). Зовёт Enemy.
func bounce() -> void:
	velocity.y = jump_velocity * 0.85
	_can_dash = true
	_add_shake(jump_shake)
	Sfx.play("jump", 1.15)

## Разблокировать двойной прыжок (способность-гейт). Зовёт пикап Ability.
func unlock_double_jump() -> void:
	_has_double_jump = true
	_air_jumps = max_air_jumps


## Прибытие в комнату (World при переходе): встать сюда, обнулить инерцию и сделать
## это точкой возрождения, пока не тронут чекпоинт внутри новой комнаты.
func arrive(pos: Vector2) -> void:
	global_position = pos
	_checkpoint = pos
	velocity = Vector2.ZERO
	_dashing = false
	_dash_cd = 0.0
	_can_dash = true
	_coyote = 0.0
	_buffer = 0.0
	_wall_lock = 0.0
	_was_on_floor = false
	_dead = false

## Короткий стоп-кадр (freeze frame) — «удар» момента смерти. Идёт в реальном времени.
func _hitstop(duration: float) -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

## Добавить тряску (берём максимум — сильный удар не гасится слабым).
func _add_shake(amount: float) -> void:
	_shake = maxf(_shake, amount)

## Затухающая тряска: дрожь смещения камеры, плавно к нулю.
func _update_shake(delta: float) -> void:
	if _shake > 0.0:
		_shake = maxf(_shake - shake_decay * delta, 0.0)
		_cam.offset = Vector2(randf_range(-_shake, _shake), randf_range(-_shake, _shake))
	elif _cam.offset != Vector2.ZERO:
		_cam.offset = Vector2.ZERO
