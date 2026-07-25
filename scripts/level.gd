extends Node2D
## Тест-полигон из статичных блоков (плейсхолдеры), чтобы щупать движение.
## Плюс — проверка палитры вживую (ARTBIBLE §2): выцветший мир + янтарь = жизнь.
## Позже заменим на TileMap-уровни.

func _ready() -> void:
	_background()
	_beacon(Vector2(1080, 240))                     # «маяк» вдали — тянет вглубь

	_block(Vector2(640, 700), Vector2(1400, 40))    # пол
	_block(Vector2(-40, 300), Vector2(40, 900))     # левая граница
	_block(Vector2(1320, 300), Vector2(40, 900))    # правая граница
	_block(Vector2(500, 560), Vector2(200, 24))     # платформа
	_block(Vector2(820, 440), Vector2(200, 24))     # платформа выше
	_block(Vector2(320, 400), Vector2(40, 300))     # столб для wall-jump
	_block(Vector2(1040, 520), Vector2(40, 340))    # столб для wall-jump

	_spikes(Vector2(760, 680), 260, 9)              # шипы на полу — dash/прыжок над ними
	_spikes(Vector2(500, 548), 120, 4)              # шипы на нижней платформе

	_checkpoint(Vector2(200, 660))                  # старт (у левого края)
	_checkpoint(Vector2(900, 408))                  # награда за верхнюю платформу

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
	poly.color = Palette.CH1_MID                     # игровой силуэт Гл.1
	body.add_child(poly)
	add_child(body)

## Выцветший задник (тёмная десатурированная база), чтобы янтарь читался.
func _background() -> void:
	var bg := ColorRect.new()
	bg.color = Palette.CH1_FG.lerp(Palette.CH1_MID, 0.35)
	bg.size = Vector2(4000, 2400)
	bg.position = Vector2(-1400, -900)
	bg.z_index = -100
	add_child(bg)

## Аддитивное янтарное свечение (маяк / уголёк) — web-безопасно, без Glow (ARTBIBLE §7).
func _beacon(pos: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = _radial_tex()
	s.position = pos
	s.scale = Vector2(3.5, 3.5)
	s.modulate = Palette.AMBER_LIGHT
	s.z_index = -50
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	s.material = m
	add_child(s)

## Шипы — мгновенная смерть. Area2D в группе "hazard", сам зовёт die() у игрока.
## Тёплый цвет (AMBER_DEEP): по оси палитры активное/горячее = угроза.
## base — середина основания «пилы», width — ширина ряда, count — число зубьев.
func _spikes(base: Vector2, width: float, count: int) -> void:
	var h := 26.0
	var tw := width / count
	var area := Area2D.new()
	area.position = base
	area.add_to_group("hazard")

	# Хитбокс чуть ниже и уже визуала — честнее (не убивает за кончик).
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width * 0.95, h * 0.6)
	col.shape = shape
	col.position = Vector2(0.0, -h * 0.3)
	area.add_child(col)

	# Пилообразный силуэт одним полигоном: низ ровный, верх — зубья.
	var pts := PackedVector2Array()
	pts.append(Vector2(-width * 0.5, 0.0))
	for i in count:
		pts.append(Vector2(-width * 0.5 + (i + 0.5) * tw, -h))   # пик
		pts.append(Vector2(-width * 0.5 + (i + 1.0) * tw, 0.0))  # впадина
	var poly := Polygon2D.new()
	poly.polygon = pts
	poly.color = Palette.AMBER_DEEP
	area.add_child(poly)

	area.body_entered.connect(func(b: Node) -> void:
		if b.has_method("die"):
			b.die()
	)
	add_child(area)

## Чекпоинт — тусклый уголёк, разгорается янтарём при касании (нарратив «дорога домой»).
## pos — точка, куда игрок будет возрождаться (центр тела на твёрдой земле).
func _checkpoint(pos: Vector2) -> void:
	var area := Area2D.new()
	area.position = pos
	area.add_to_group("checkpoint")

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(60, 90)
	col.shape = shape
	area.add_child(col)

	# Уголёк: скромное аддитивное свечение, пока еле тлеет. Разгорится при активации.
	var ember := Sprite2D.new()
	ember.texture = _radial_tex()
	ember.scale = Vector2(0.4, 0.4)
	ember.modulate = Color(Palette.AMBER_DEEP, 0.4)   # еле тлеет = не зажжён
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ember.material = m
	area.add_child(ember)

	var lit := [false]                                    # активируется один раз
	area.body_entered.connect(func(b: Node) -> void:
		if lit[0] or not b.has_method("set_checkpoint"):
			return
		lit[0] = true
		b.set_checkpoint(pos)
		ember.modulate = Palette.AMBER_CORE               # разгорелся
		ember.scale = Vector2(0.75, 0.75)
		Sfx.play("checkpoint")
		Fx.burst(pos, Palette.AMBER_LIGHT, 16, 120.0, 0.7)   # искры оживания
	)
	add_child(area)

## Радиальный градиент в коде (белый центр → прозрачность), тонируется modulate.
func _radial_tex() -> Texture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 256
	t.height = 256
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	return t
