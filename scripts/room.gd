extends Node2D
class_name Room
## База комнаты Главы 1: тайлсет-силуэт из палитры (кромка+rim-light), параллакс,
## шипы, чекпоинты, двери. Конкретная комната наследует Room и переопределяет build().
## World свапает комнаты, читая `size` (границы камеры) и `entries` (точки спавна).

const TILE := 32

signal exit_taken(target: String, entry: String)

var size := Vector2i(40, 23)          ## размер комнаты в тайлах (переопредели в build)
var entries := {}                     ## имя двери -> Vector2 (куда ставить игрока)
var _tiles: TileMapLayer
var _far: ParallaxLayer
var _mid: ParallaxLayer

func _ready() -> void:
	_make_parallax()
	_tiles = TileMapLayer.new()
	_tiles.tile_set = _build_tileset()
	_tiles.z_index = -10                            # уровень за игроком
	add_child(_tiles)
	build()

## Переопредели в наследнике: раскладка тайлов, шипы, чекпоинты, маяк, двери, входы.
func build() -> void:
	pass

# ── Геометрия ────────────────────────────────────────────────────────────────

## Заливка прямоугольника тайлами: верхний ряд — с rim-light, ниже — сплошной.
func _fill(x: int, y: int, w: int, h: int) -> void:
	for i in range(x, x + w):
		for j in range(y, y + h):
			var t := 0 if j == y else 1             # 0 = кромка (rim), 1 = сплошной
			_tiles.set_cell(Vector2i(i, j), 0, Vector2i(t, 0), 0)

## Вход-точка: куда World ставит игрока, придя через эту дверь.
func _entry(name: String, pos: Vector2) -> void:
	entries[name] = pos

## Дверь: зона у края; вход игрока → сигнал перехода в target-комнату к её entry.
func _exit(rect: Rect2, target: String, entry: String) -> void:
	var area := Area2D.new()
	area.position = rect.position + rect.size * 0.5
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	area.add_child(col)
	var taken := [false]
	area.body_entered.connect(func(b: Node) -> void:
		if taken[0] or not b.is_in_group("player"):
			return
		taken[0] = true
		exit_taken.emit(target, entry)
	)
	add_child(area)

# ── Тайлсет ──────────────────────────────────────────────────────────────────

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

# ── Атмосфера ────────────────────────────────────────────────────────────────

## Параллакс-задник (ARTBIBLE §6): слой -1 = позади геймплея. Хранит _far/_mid слои.
func _make_parallax() -> void:
	var pb := ParallaxBackground.new()
	pb.layer = -1
	add_child(pb)

	_far = ParallaxLayer.new()
	_far.motion_scale = Vector2(0.15, 0.15)
	pb.add_child(_far)

	var base := ColorRect.new()
	base.color = Palette.CH1_FG.lerp(Palette.CH1_MID, 0.3)   # выцветшая база
	base.size = Vector2(6000, 3600)
	base.position = Vector2(-2200, -1400)
	_far.add_child(base)

	var fog := Sprite2D.new()                        # мягкий туман/небо сверху
	fog.texture = _fog_tex()
	fog.centered = false
	fog.position = Vector2(-800, -300)
	fog.scale = Vector2(60, 8)
	_far.add_child(fog)

	_mid = ParallaxLayer.new()
	_mid.motion_scale = Vector2(0.5, 0.5)
	pb.add_child(_mid)

## Маяк — тёплое сердце в глубине (аддитив, web-safe, без Glow). В дальний слой.
func _beacon(pos: Vector2) -> void:
	var b := Sprite2D.new()
	b.texture = _radial_tex()
	b.position = pos
	b.scale = Vector2(3.5, 3.5)
	b.modulate = Palette.AMBER_LIGHT
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	b.material = m
	_far.add_child(b)

## Тёмный силуэт дальнего плана (почти чёрная форма — глубина без деталей). В средний слой.
func _silhouette(center: Vector2, sz: Vector2) -> void:
	var h := sz * 0.5
	var poly := Polygon2D.new()
	poly.position = center
	poly.polygon = PackedVector2Array([
		Vector2(-h.x, -h.y), Vector2(h.x * 0.6, -h.y * 0.7),
		Vector2(h.x, h.y), Vector2(-h.x, h.y)])       # скошенный силуэт-гряда
	poly.color = Palette.CH1_FG.lerp(Palette.CH1_MID, 0.12)
	_mid.add_child(poly)

# ── Опасности и чекпоинты ────────────────────────────────────────────────────

## Шипы — мгновенная смерть. Area2D в группе "hazard", сам зовёт die() у игрока.
func _spikes(base: Vector2, width: float, count: int) -> void:
	var h := 26.0
	var tw := width / count
	var area := Area2D.new()
	area.position = base
	area.add_to_group("hazard")

	var col := CollisionShape2D.new()                # хитбокс чуть ниже/уже визуала — честнее
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width * 0.95, h * 0.6)
	col.shape = shape
	col.position = Vector2(0.0, -h * 0.3)
	area.add_child(col)

	var pts := PackedVector2Array()                  # пилообразный силуэт одним полигоном
	pts.append(Vector2(-width * 0.5, 0.0))
	for i in count:
		pts.append(Vector2(-width * 0.5 + (i + 0.5) * tw, -h))
		pts.append(Vector2(-width * 0.5 + (i + 1.0) * tw, 0.0))
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
func _checkpoint(pos: Vector2) -> void:
	var area := Area2D.new()
	area.position = pos
	area.add_to_group("checkpoint")

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(60, 90)
	col.shape = shape
	area.add_child(col)

	var ember := Sprite2D.new()                      # еле тлеет, пока не зажжён
	ember.texture = _radial_tex()
	ember.scale = Vector2(0.4, 0.4)
	ember.modulate = Color(Palette.AMBER_DEEP, 0.4)
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ember.material = m
	area.add_child(ember)

	var lit := [false]
	area.body_entered.connect(func(b: Node) -> void:
		if lit[0] or not b.has_method("set_checkpoint"):
			return
		lit[0] = true
		b.set_checkpoint(pos)
		ember.modulate = Palette.AMBER_CORE
		ember.scale = Vector2(0.75, 0.75)
		Sfx.play("checkpoint")
		Fx.burst(pos, Palette.AMBER_LIGHT, 16, 120.0, 0.7)
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
