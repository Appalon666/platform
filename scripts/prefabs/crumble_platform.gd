extends StaticBody2D
class_name CrumblePlatform
## Осыпающаяся платформа: наступил → янтарная вспышка (delay) → пропадает (падаешь) →
## возвращается через respawn. Сенсор сверху ловит момент, когда игрок встал на неё.

@export var delay := 0.5      ## задержка перед обвалом (сек)
@export var respawn := 2.5    ## через сколько появится снова (сек)

var _triggered := false
@onready var _col: CollisionShape2D = $Col
@onready var _vis: Node2D = $Vis

func _ready() -> void:
	$Top.body_entered.connect(_on_top)

func _on_top(b: Node) -> void:
	if _triggered or not b.is_in_group("player"):
		return
	_triggered = true
	_crumble()

func _crumble() -> void:
	create_tween().tween_property(_vis, "modulate", Color(1.0, 0.7, 0.45), delay)
	await get_tree().create_timer(delay).timeout
	_col.set_deferred("disabled", true)
	_vis.visible = false
	Sfx.play("land", 0.6)
	Fx.dust(global_position, Palette.CH1_FOG, 10)
	await get_tree().create_timer(respawn).timeout
	_vis.modulate = Color.WHITE
	_vis.visible = true
	_col.set_deferred("disabled", false)
	_triggered = false
