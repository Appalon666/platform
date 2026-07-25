extends Area2D
class_name Mote
## Янтарная мошка — коллекционка (награда за исследование, в духе Lums из Rayman).
## У каждой уникальный id; собранная не появляется снова (Progress хранит id).

@export var id: String = ""

func _ready() -> void:
	if Progress.is_collected(id):
		queue_free()
		return
	body_entered.connect(_on_body)

func _on_body(b: Node) -> void:
	if not b.is_in_group("player"):
		return
	Progress.collect(id)
	Sfx.play("checkpoint", 1.6)
	Fx.burst(global_position, Palette.AMBER_LIGHT, 10, 100.0, 0.4, "glow")
	queue_free()
