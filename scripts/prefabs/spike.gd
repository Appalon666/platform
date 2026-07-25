extends Area2D
class_name Spike
## Шипы = мгновенная смерть. Визуал/коллизия заданы в Spike.tscn.
## Перетащи в комнату, при нужде масштабируй по X или дублируй ряд.

func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(func(b: Node) -> void:
		if b.has_method("die"):
			b.die()
	)
