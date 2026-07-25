extends Area2D
class_name Door
## Дверь на краю комнаты. Вход игрока → переход в комнату `target` к её входу `entry`.
## Перетащи Door.tscn в комнату, задай target ("room2") и entry ("from_west").

@export var target: String = ""
@export var entry: String = ""
var _taken := false

func _ready() -> void:
	body_entered.connect(_on_body)

func _on_body(b: Node) -> void:
	if _taken or not b.is_in_group("player"):
		return
	_taken = true
	var w := get_tree().get_first_node_in_group("world")
	if w != null:
		w.call_deferred("go_to", target, entry)   # свап после кадра физики
