extends Area2D
class_name Wind
## Восходящий поток — пока игрок внутри, мягко тянет его вверх, перебивая гравитацию.
## Ставь над пропастями/шахтами: даёт вертикальную траверсу без платформ.
## Растяни коллизию и высоту частиц под нужную шахту.

@export var force := 1500.0   ## Ускорение потока вверх (px/с²)
@export var max_up := 440.0   ## Максимальная скорость подъёма внутри потока

func _ready() -> void:
	add_to_group("wind")
	body_entered.connect(_on_body)
	body_exited.connect(_off_body)

func _on_body(b: Node) -> void:
	if b.is_in_group("player"):
		b.enter_wind(self)

func _off_body(b: Node) -> void:
	if b.is_in_group("player"):
		b.exit_wind(self)
