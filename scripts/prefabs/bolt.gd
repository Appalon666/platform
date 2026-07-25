extends Area2D
class_name Bolt
## Снаряд стрелка: летит по dir, убивает игрока, гибнет о стену или по таймауту.

var dir := Vector2.RIGHT
@export var speed := 300.0
var _life := 4.0

func _ready() -> void:
	add_to_group("bolt")
	body_entered.connect(_on_body)

func _physics_process(delta: float) -> void:
	position += dir * speed * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_body(b: Node) -> void:
	if b.is_in_group("player") and b.has_method("die"):
		b.die()
	queue_free()                         # гибнет о любую преграду (игрок/стена)
