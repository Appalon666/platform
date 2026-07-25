extends Node
## Одноразовые партиклы через CPUParticles2D (web-safe, GL Compatibility — без GPU-частиц).
## Текстуры — Kenney Particle Pack (CC0), тонируются цветом партикла в наш янтарь.
## Автолоад «Fx»: живёт в корне дерева, эффект остаётся на месте, даже когда игрок улетел.
## Вызов: Fx.burst(pos, color) / Fx.dust(pos, color).

const VFX := "res://assets/vfx/kenney_particles/"
var _tex := {}

func _ready() -> void:
	_tex["glow"]  = _load("circle_05")   # мягкое свечение — уголёк/жизнь
	_tex["spark"] = _load("spark_04")    # острая искра — энергия рывка
	_tex["smoke"] = _load("smoke_05")    # клуб дыма/пыли
	_tex["dirt"]  = _load("dirt_02")     # комок земли — кик при приземлении

func _load(n: String) -> Texture2D:
	return load(VFX + n + ".png") as Texture2D

## Взрыв во все стороны (dash — искры, смерть — мягкие угольки через tex="glow").
func burst(pos: Vector2, color: Color, amount := 14, speed := 200.0, life := 0.5, tex := "spark") -> void:
	var p := _make(pos, color, amount, life, _pick(tex))
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = speed * 0.35
	p.initial_velocity_max = speed
	p.gravity = Vector2(0, 620)
	_launch(p, life)

## Пыль из-под ног (приземление/прыжок): дым узким веером, медленно оседает.
func dust(pos: Vector2, color: Color, amount := 8, tex := "smoke") -> void:
	var p := _make(pos, color, amount, 0.55, _pick(tex))
	p.direction = Vector2.UP
	p.spread = 55.0
	p.initial_velocity_min = 35.0
	p.initial_velocity_max = 110.0
	p.gravity = Vector2(0, 170)
	_launch(p, 0.55)

func _pick(name: String) -> Texture2D:
	return _tex.get(name, _tex["glow"])

func _make(pos: Vector2, color: Color, amount: int, life: float, tex: Texture2D) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = pos
	p.texture = tex
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = life
	p.color = color
	p.scale_amount_min = 0.03          # текстуры 512px → масштаб маленький
	p.scale_amount_max = 0.10
	p.damping_min = 40.0
	p.damping_max = 90.0
	return p

func _launch(p: CPUParticles2D, life: float) -> void:
	add_child(p)
	p.emitting = true
	get_tree().create_timer(life + 0.3).timeout.connect(p.queue_free)
