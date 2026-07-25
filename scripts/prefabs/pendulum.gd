extends Node2D
class_name Pendulum
## Маятник: шипованный груз на цепи качается из стороны в сторону вокруг точки крепления.
## Касание груза = смерть. Несколько маятников можно рассинхронить через phase.

@export var amplitude := 0.9       ## макс. отклонение от вертикали (радианы, ~51°)
@export var speed := 1.4           ## угловая частота качания
@export var phase := 0.0           ## сдвиг фазы (рассинхронить соседние маятники)

var _t := 0.0
@onready var _arm: Node2D = $Arm

func _ready() -> void:
	add_to_group("enemy")
	$Arm/Bob/Hitbox.body_entered.connect(func(b: Node) -> void:
		if b.is_in_group("player") and b.has_method("die"):
			b.die()
	)

func _process(delta: float) -> void:
	_t += delta
	_arm.rotation = amplitude * sin(_t * speed + phase)
