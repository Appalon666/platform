extends Node2D
## Тест-полигон из статичных блоков (плейсхолдеры), чтобы щупать движение:
## пол, стены для wall-jump, пара платформ. Позже заменим на TileMap-уровни.

func _ready() -> void:
	_block(Vector2(640, 700), Vector2(1400, 40))   # пол
	_block(Vector2(-40, 300), Vector2(40, 900))    # левая граница
	_block(Vector2(1320, 300), Vector2(40, 900))   # правая граница
	_block(Vector2(500, 560), Vector2(200, 24))    # платформа
	_block(Vector2(820, 440), Vector2(200, 24))    # платформа выше
	_block(Vector2(320, 400), Vector2(40, 300))    # столб для wall-jump
	_block(Vector2(1040, 520), Vector2(40, 340))   # столб для wall-jump

func _block(center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = center
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	var poly := Polygon2D.new()
	var h := size * 0.5
	poly.polygon = PackedVector2Array([
		Vector2(-h.x, -h.y), Vector2(h.x, -h.y),
		Vector2(h.x, h.y), Vector2(-h.x, h.y),
	])
	poly.color = Color(0.15, 0.17, 0.22)
	body.add_child(poly)
	add_child(body)
