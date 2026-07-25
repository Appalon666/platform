extends Area2D
class_name Ability
## Пикап способности «двойной прыжок» — янтарный осколок движения. Касание игроком →
## разблокировка + исчезает. Способность живёт на игроке, сохраняется между комнатами.

func _ready() -> void:
	body_entered.connect(_on_body)

func _on_body(b: Node) -> void:
	if not b.is_in_group("player") or not b.has_method("unlock_double_jump"):
		return
	b.unlock_double_jump()
	Sfx.play("checkpoint", 1.4)
	Fx.burst(global_position, Palette.AMBER_LIGHT, 28, 240.0, 0.9, "glow")
	queue_free()
