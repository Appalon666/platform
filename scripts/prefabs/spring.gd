extends StaticBody2D
class_name Spring
## Пружина-батут: игрок приземляется сверху → мощный запуск вверх. Твёрдая площадка +
## сенсор сверху. Настрой силу launch в инспекторе.

@export var launch := 980.0

@onready var _vis: Node2D = $Vis

func _ready() -> void:
	$Top.body_entered.connect(_on_top)

func _on_top(b: Node) -> void:
	if not b.is_in_group("player") or not b.has_method("launch"):
		return
	b.launch(launch)
	Sfx.play("jump", 0.7)
	Fx.burst(global_position, Palette.AMBER_LIGHT, 12, 180.0, 0.4, "spark")
	_vis.scale.y = 0.5                    # сжатие пружины
	create_tween().tween_property(_vis, "scale:y", 1.0, 0.25).set_trans(Tween.TRANS_ELASTIC)
