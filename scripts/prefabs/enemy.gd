extends CharacterBody2D
class_name Enemy
## Патрульный враг «потревоженное застывшее». Ходит по полу, разворачивается у стен и
## на границе диапазона. Контакт сбоку/снизу = смерть игрока; прыжок сверху = стомп
## (враг гибнет, игрок отскакивает). Слой 2 — игрок сквозь него проходит (не блок).

@export var speed := 60.0
@export var gravity := 1400.0
@export var patrol_range := 160.0     ## насколько далеко уходит от старта (px)

var _dir := -1.0
var _origin_x := 0.0
@onready var _vis: Node2D = $Vis

func _ready() -> void:
	add_to_group("enemy")
	_origin_x = global_position.x
	$Hitbox.body_entered.connect(_on_touch)

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = _dir * speed
	move_and_slide()
	# разворот у стены или на границе патруля
	if is_on_wall() or absf(global_position.x - _origin_x) > patrol_range:
		_dir = -_dir
	_vis.scale.x = -1.0 if _dir < 0.0 else 1.0

func _on_touch(b: Node) -> void:
	if not b.is_in_group("player"):
		return
	# стомп: игрок падает и находится выше центра врага
	if b.velocity.y > 50.0 and b.global_position.y < global_position.y - 6.0:
		if b.has_method("bounce"):
			b.bounce()
		_die()
	elif b.has_method("die"):
		b.die()

func _die() -> void:
	Fx.burst(global_position, Palette.AMBER_LIGHT, 14, 180.0, 0.5, "glow")
	Sfx.play("land", 0.7)
	queue_free()
