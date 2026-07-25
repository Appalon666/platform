extends Node
## Одноразовые партиклы через CPUParticles2D (web-safe, GL Compatibility — без GPU-частиц).
## Автолоад «Fx»: живёт в корне дерева, поэтому эффект остаётся на месте, даже когда
## игрок улетел на респаун. Вызов: Fx.burst(pos, color) / Fx.dust(pos, color).

var _dot: Texture2D

func _ready() -> void:
	_dot = _make_dot()

## Взрыв во все стороны (dash, смерть). amount — сколько искр, speed — разлёт.
func burst(pos: Vector2, color: Color, amount := 14, speed := 200.0, life := 0.5) -> void:
	var p := _make(pos, color, amount, life)
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = speed * 0.35
	p.initial_velocity_max = speed
	p.gravity = Vector2(0, 620)
	_launch(p, life)

## Пыль из-под ног (приземление). Летит вверх узким веером и оседает.
func dust(pos: Vector2, color: Color, amount := 8) -> void:
	var p := _make(pos, color, amount, 0.4)
	p.direction = Vector2.UP
	p.spread = 55.0
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 120.0
	p.gravity = Vector2(0, 220)
	_launch(p, 0.4)

func _make(pos: Vector2, color: Color, amount: int, life: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = pos
	p.texture = _dot
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = life
	p.color = color
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.5
	p.damping_min = 40.0
	p.damping_max = 90.0
	return p

func _launch(p: CPUParticles2D, life: float) -> void:
	add_child(p)
	p.emitting = true
	get_tree().create_timer(life + 0.3).timeout.connect(p.queue_free)

## Мягкая круглая точка (белый центр → прозрачность), тонируется цветом партикла.
func _make_dot() -> Texture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 12
	t.height = 12
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	return t
