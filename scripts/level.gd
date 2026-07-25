extends Node2D
## Комната Главы 1 «Окраина» на TileMap (плейсхолдер-тайлсет из палитры, ARTBIBLE §2/§3):
## выцветший силуэт CH1_MID + тонкий rim-light сверху. Шипы, чекпоинты, маяк — поверх.
## Пайплайн арта: цветные блоки → ЭТОТ тайл-силуэт → свой арт в Krita (позже).

const TILE := 32                                    # размер тайла, px
const ROOM_W := 40                                  # ширина комнаты в тайлах
const ROOM_H := 23                                  # высота комнаты в тайлах
var _tiles: TileMapLayer

func _ready() -> void:
	_parallax()
	_build_room()
	_camera_limits()

	_spikes(Vector2(560, 640), 160, 6)              # шипы на полу — перепрыгнуть

	_checkpoint(Vector2(100, 620))                  # старт
	_checkpoint(Vector2(608, 428))                  # середина (на платформе P3)
	_checkpoint(Vector2(1168, 108))                 # цель — верх wall-jump-шахты

## Раскладка комнаты (40×23 тайла = 1280×736): пол/стены/потолок + лесенка платформ.
func _build_room() -> void:
	_tiles = TileMapLayer.new()
	_tiles.tile_set = _build_tileset()
	_tiles.z_index = -10                            # уровень за игроком
	add_child(_tiles)

	_fill(0, 0, 40, 1)                              # потолок
	_fill(0, 20, 40, 3)                             # пол
	_fill(0, 0, 2, 23)                              # левая стена
	_fill(38, 0, 2, 23)                             # правая стена

	_fill(5, 18, 4, 1)                              # P1
	_fill(11, 16, 4, 1)                             # P2
	_fill(17, 14, 4, 1)                             # P3
	_fill(23, 12, 4, 1)                             # P4
	_fill(29, 11, 3, 1)                             # ступень к шахте

	_fill(34, 5, 1, 15)                             # столб wall-jump-шахты
	_fill(35, 4, 3, 1)                              # цель-карниз над шахтой

## Заливка прямоугольника тайлами: верхний ряд — с rim-light, ниже — сплошной.
func _fill(x: int, y: int, w: int, h: int) -> void:
	for i in range(x, x + w):
		for j in range(y, y + h):
			var t := 0 if j == y else 1             # 0 = кромка (rim), 1 = сплошной
			_tiles.set_cell(Vector2i(i, j), 0, Vector2i(t, 0), 0)

## Тайлсет из палитры: 2 тайла (кромка / сплошной), у каждого квадратная коллизия.
func _build_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)      # тайлы на слое 1 — игрок его сканирует
	ts.set_physics_layer_collision_mask(0, 1)
	var src := TileSetAtlasSource.new()
	src.texture = _tile_atlas()
	src.texture_region_size = Vector2i(TILE, TILE)
	for ax in 2:
		src.create_tile(Vector2i(ax, 0))
	ts.add_source(src, 0)                           # прикрепить ДО правки коллизии,
	                                                # иначе physics-слой тайлам не виден
	var hs := TILE * 0.5
	var sq := PackedVector2Array([
		Vector2(-hs, -hs), Vector2(hs, -hs), Vector2(hs, hs), Vector2(-hs, hs)])
	for ax in 2:
		var td := src.get_tile_data(Vector2i(ax, 0), 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, sq)
	return ts

## Атлас 2×1: тайл 0 — силуэт с rim-light сверху; тайл 1 — сплошной чуть темнее (глубина).
func _tile_atlas() -> ImageTexture:
	var img := Image.create(TILE * 2, TILE, false, Image.FORMAT_RGBA8)
	var mid := Palette.CH1_MID
	var rim := mid.lerp(Palette.CH1_FOG, 0.6)
	var deep := mid.lerp(Palette.CH1_FG, 0.18)
	for x in TILE:
		for y in TILE:
			var c := mid
			if y == 0: c = rim
			elif y == 1: c = mid.lerp(rim, 0.5)
			img.set_pixel(x, y, c)                  # тайл 0 (кромка)
			img.set_pixel(TILE + x, y, deep)        # тайл 1 (сплошной)
	return ImageTexture.create_from_image(img)

## Ограничить камеру границами комнаты — не показываем пустоту за стенами.
## Камера живёт на игроке (player.tscn); лимиты ставит комната → каждая задаёт свои.
func _camera_limits() -> void:
	var cam := get_node_or_null("Player/Camera2D") as Camera2D
	if cam == null:
		return
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = ROOM_W * TILE
	cam.limit_bottom = ROOM_H * TILE

## Параллакс-задник (ARTBIBLE §6): три плана глубины. Слой -1 = позади геймплея.
func _parallax() -> void:
	var pb := ParallaxBackground.new()
	pb.layer = -1
	add_child(pb)

	# Дальний слой (едва движется — «далеко, но тянет»): база + туман + маяк.
	var far := ParallaxLayer.new()
	far.motion_scale = Vector2(0.15, 0.15)
	pb.add_child(far)

	var base := ColorRect.new()
	base.color = Palette.CH1_FG.lerp(Palette.CH1_MID, 0.3)   # выцветшая база
	base.size = Vector2(5000, 3000)
	base.position = Vector2(-1800, -1100)
	far.add_child(base)

	var fog := Sprite2D.new()                        # мягкий туман/небо сверху
	fog.texture = _fog_tex()
	fog.centered = false
	fog.position = Vector2(-600, -300)
	fog.scale = Vector2(40, 8)
	far.add_child(fog)

	var b := Sprite2D.new()                          # маяк — тёплое сердце в глубине
	b.texture = _radial_tex()
	b.position = Vector2(1120, 240)
	b.scale = Vector2(3.5, 3.5)
	b.modulate = Palette.AMBER_LIGHT
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	b.material = m
	far.add_child(b)

	# Средний слой: дальние тёмные силуэты-гряды для глубины.
	var mid := ParallaxLayer.new()
	mid.motion_scale = Vector2(0.5, 0.5)
	pb.add_child(mid)
	_silhouette(mid, Vector2(260, 720), Vector2(620, 460))
	_silhouette(mid, Vector2(1000, 760), Vector2(760, 520))

## Тёмный силуэт дальнего плана (почти чёрная форма — глубина без деталей).
func _silhouette(layer: ParallaxLayer, center: Vector2, size: Vector2) -> void:
	var h := size * 0.5
	var poly := Polygon2D.new()
	poly.position = center
	poly.polygon = PackedVector2Array([
		Vector2(-h.x, -h.y), Vector2(h.x * 0.6, -h.y * 0.7),
		Vector2(h.x, h.y), Vector2(-h.x, h.y)])       # скошенный силуэт-гряда
	poly.color = Palette.CH1_FG.lerp(Palette.CH1_MID, 0.12)
	layer.add_child(poly)

## Вертикальный градиент тумана (CH1_FOG сверху → прозрачность вниз).
func _fog_tex() -> Texture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([Color(Palette.CH1_FOG, 0.35), Color(Palette.CH1_FOG, 0.0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 32
	t.height = 128
	t.fill = GradientTexture2D.FILL_LINEAR
	t.fill_from = Vector2(0.0, 0.0)
	t.fill_to = Vector2(0.0, 1.0)
	return t

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
