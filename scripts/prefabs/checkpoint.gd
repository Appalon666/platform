extends Area2D
class_name Checkpoint
## Чекпоинт-уголёк: разгорается янтарём при касании, задаёт точку возрождения.
## Перетащи Checkpoint.tscn в комнату на твёрдую землю.

var _lit := false
@onready var _ember: Sprite2D = $Ember

func _ready() -> void:
	add_to_group("checkpoint")
	body_entered.connect(_on_body)

func _on_body(b: Node) -> void:
	if _lit or not b.has_method("set_checkpoint"):
		return
	_lit = true
	b.set_checkpoint(global_position)
	_ember.modulate = Palette.AMBER_CORE
	_ember.scale = Vector2(0.55, 0.55)
	Sfx.play("checkpoint")
	Fx.burst(global_position, Palette.AMBER_LIGHT, 16, 120.0, 0.7)
