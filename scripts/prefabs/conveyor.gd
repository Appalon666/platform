extends StaticBody2D
class_name Conveyor
## Конвейер: пока игрок стоит сверху, лента тянет его в сторону.
## Используем встроенное constant_linear_velocity StaticBody2D — move_and_slide игрока
## подхватывает скорость поверхности. belt_speed>0 — вправо, <0 — влево.
## Стрелки на ленте прокручиваются в направлении движения.

@export var belt_speed := 120.0

var _scroll := 0.0
@onready var _chev: Node2D = $Chevrons

func _ready() -> void:
	constant_linear_velocity = Vector2(belt_speed, 0.0)
	_chev.scale.x = -1.0 if belt_speed < 0.0 else 1.0

func _process(delta: float) -> void:
	_scroll += absf(belt_speed) * delta
	_chev.position.x = fmod(_scroll, 32.0)
