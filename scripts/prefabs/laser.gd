extends Node2D
class_name Laser
## Лазер по циклу: покой → зарядка (тонкий телеграф) → выстрел (толстый луч, летально).
## Стреляет вдоль локального +X — поверни инстанс (rotation) под нужную сторону.
## Луч убивает, пока горит; проходить надо в фазу покоя. start_delay рассинхронит соседние.

@export var length := 260.0
@export var thickness := 12.0
@export var off_time := 1.4
@export var warn_time := 0.45
@export var on_time := 1.0
@export var start_delay := 0.0

var _t := 0.0
var _phase := "off"
@onready var _beam: Polygon2D = $Beam
@onready var _core: Line2D = $Core
@onready var _hit: Area2D = $Hit

func _ready() -> void:
	add_to_group("enemy")
	var h := thickness * 0.5
	_beam.polygon = PackedVector2Array([Vector2(0, -h), Vector2(length, -h), Vector2(length, h), Vector2(0, h)])
	_core.points = PackedVector2Array([Vector2(0, 0), Vector2(length, 0)])
	var cs := _hit.get_node("HitShape") as CollisionShape2D
	var shp := RectangleShape2D.new()
	shp.size = Vector2(length, thickness)
	cs.shape = shp
	cs.position = Vector2(length * 0.5, 0.0)
	_hit.monitoring = true
	_t = -start_delay
	_apply()

func _process(delta: float) -> void:
	_t += delta
	var dur := on_time
	if _phase == "off":
		dur = off_time
	elif _phase == "warn":
		dur = warn_time
	if _t >= dur:
		_t -= dur
		_phase = "warn" if _phase == "off" else ("on" if _phase == "warn" else "off")
		_apply()
	if _phase == "on":
		for b in _hit.get_overlapping_bodies():
			if b.is_in_group("player") and b.has_method("die"):
				b.die()

func _apply() -> void:
	match _phase:
		"off":
			_beam.visible = false
			_core.visible = false
		"warn":
			_beam.visible = false
			_core.visible = true
			_core.modulate = Color(1.0, 0.55, 0.5, 0.9)
			_core.width = 2.0
		"on":
			_beam.visible = true
			_core.visible = true
			_core.modulate = Color(1.0, 1.0, 0.95, 1.0)
			_core.width = 4.0
