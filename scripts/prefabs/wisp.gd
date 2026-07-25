extends Node2D
class_name Wisp
## Летающий дух-преследователь. В радиусе sight замечает игрока и плавно тянется к нему;
## держит цель, пока тот не уйдёт за leash — тогда возвращается домой и покачивается.
## Контакт = смерть. Обходится манёвром, дэшем или заманиванием в шипы. Слой 2 (не блок).

@export var speed := 120.0
@export var accel := 5.0          ## как резко доворачивает к цели (плавность/инерция полёта)
@export var sight := 340.0        ## радиус, в котором замечает игрока
@export var leash := 640.0        ## дальше этого теряет игрока и уходит к origin

var _vel := Vector2.ZERO
var _origin := Vector2.ZERO
var _aggro := false
var _t := 0.0
@onready var _vis: Node2D = $Vis

func _ready() -> void:
	add_to_group("enemy")
	_origin = global_position
	$Hitbox.body_entered.connect(func(b: Node) -> void:
		if b.is_in_group("player") and b.has_method("die"):
			b.die()
	)

func _process(delta: float) -> void:
	_t += delta
	var target := _origin + Vector2(0.0, sin(_t * 2.0) * 10.0)   # дома тихо покачивается
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p := players[0] as Node2D
		var d := p.global_position.distance_to(global_position)
		if _aggro:
			if d > leash:
				_aggro = false
			else:
				target = p.global_position
		elif d < sight:
			_aggro = true
			target = p.global_position

	var desired := (target - global_position).normalized() * speed
	_vel = _vel.lerp(desired, accel * delta)
	global_position += _vel * delta
	if absf(_vel.x) > 4.0:
		_vis.scale.x = -1.0 if _vel.x < 0.0 else 1.0
