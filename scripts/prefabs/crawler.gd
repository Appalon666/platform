extends Node2D
class_name Crawler
## Ползун по стенам/потолку: патрулирует по оси в диапазоне range, приклеен к поверхности.
## vertical=true — вверх-вниз (стена); false — влево-вправо (потолок/пол). Контакт = смерть.

@export var speed := 72.0
@export var vertical := false
@export var range := 160.0

var _dir := 1.0
var _origin := Vector2.ZERO
@onready var _vis: Node2D = $Vis

func _ready() -> void:
	add_to_group("enemy")
	_origin = position
	$Hitbox.body_entered.connect(func(b: Node) -> void:
		if b.is_in_group("player") and b.has_method("die"):
			b.die()
	)

func _process(delta: float) -> void:
	var axis := Vector2.DOWN if vertical else Vector2.RIGHT
	position += axis * _dir * speed * delta
	if absf((position - _origin).dot(axis)) > range:
		_dir = -_dir
	if not vertical:
		_vis.scale.x = -1.0 if _dir < 0.0 else 1.0
