extends AnimatableBody2D
class_name MovingPlatform
## Движущаяся платформа: плавно ходит туда-обратно по offset за duration (в одну сторону).
## AnimatableBody2D несёт стоящего игрока. Настрой offset/duration в инспекторе.

@export var offset := Vector2(224, 0)   ## смещение от старта до дальней точки
@export var duration := 2.5             ## время в одну сторону (сек)

var _start: Vector2
var _t := 0.0

func _ready() -> void:
	_start = position

func _physics_process(delta: float) -> void:
	_t += delta / maxf(duration, 0.05)
	position = _start + offset * (0.5 - 0.5 * cos(_t * PI))   # плавный пинг-понг
