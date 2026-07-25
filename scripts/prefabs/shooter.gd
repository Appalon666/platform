extends Node2D
class_name Shooter
## Стационарный стрелок-«страж»: периодически пускает снаряд. Стомп сверху убивает его,
## контакт сбоку убивает игрока. Красно-янтарный «глаз» = дальняя угроза.

@export var interval := 2.0            ## период между выстрелами (сек)
@export var facing := -1.0             ## -1 стреляет влево, +1 вправо
@export var toward_player := false     ## целиться в игрока (иначе строго по facing)

var _t := 0.0
const BOLT := preload("res://scenes/prefabs/Bolt.tscn")
@onready var _hitbox: Area2D = $Hitbox
@onready var _vis: Node2D = $Vis

func _ready() -> void:
	add_to_group("enemy")
	_t = interval * 0.6
	_vis.scale.x = signf(facing)
	_hitbox.body_entered.connect(_on_touch)

func _process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0:
		_fire()
		_t = interval

func _fire() -> void:
	var b := BOLT.instantiate()
	get_parent().add_child(b)
	b.global_position = global_position + Vector2(facing * 22.0, -6.0)
	var d := Vector2(facing, 0.0)
	if toward_player:
		var p := get_tree().get_first_node_in_group("player")
		if p != null:
			d = (p.global_position - global_position).normalized()
	b.dir = d
	Sfx.play("dash", 1.5)

func _on_touch(b: Node) -> void:
	if not b.is_in_group("player"):
		return
	if b.velocity.y > 50.0 and b.global_position.y < global_position.y - 6.0:
		if b.has_method("bounce"):
			b.bounce()
		_die()
	elif b.has_method("die"):
		b.die()

func _die() -> void:
	Fx.burst(global_position, Palette.AMBER_LIGHT, 16, 200.0, 0.5, "glow")
	Sfx.play("land", 0.7)
	queue_free()
