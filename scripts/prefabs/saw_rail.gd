extends Node2D
class_name SawRail
## Пила на рельсе: крутящееся лезвие ездит вперёд-назад по прямому треку с постоянной
## скоростью, разворачиваясь на краях. Касание = смерть. vertical=true — рельс вертикальный.

@export var travel := 220.0     ## половина длины рельса — ход в каждую сторону (px)
@export var speed := 170.0      ## скорость движения по рельсу
@export var vertical := false   ## true — ездит вверх-вниз
@export var spin := 12.0        ## скорость вращения лезвия (рад/с)

var _dir := 1.0
@onready var _blade: Node2D = $Blade
@onready var _disc: Node2D = $Blade/Disc

func _ready() -> void:
	add_to_group("enemy")
	var axis := _axis()
	$Rail.points = PackedVector2Array([axis * -travel, axis * travel])
	$Blade/Hitbox.body_entered.connect(func(b: Node) -> void:
		if b.is_in_group("player") and b.has_method("die"):
			b.die()
	)

func _axis() -> Vector2:
	return Vector2.DOWN if vertical else Vector2.RIGHT

func _process(delta: float) -> void:
	var axis := _axis()
	_blade.position += axis * _dir * speed * delta
	if absf(_blade.position.dot(axis)) > travel:
		_dir = -_dir
	_disc.rotation += spin * delta
