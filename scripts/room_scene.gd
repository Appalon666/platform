extends Node2D
class_name RoomScene
## База нарисованной комнаты (.tscn). Даёт атмосферу-параллакс, авто-размер из
## нарисованного TileMapLayer и сбор входов (Entry) для World.
## Требует дочерний узел "Tiles" (TileMapLayer с ch1_tileset). Двери/шипы/чекпоинты —
## префабы, которые ты кидаешь в сцену.

@export var beacon := Vector2.ZERO      ## если задан — маяк в дальнем слое (тёплое сердце)

var size := Vector2i(40, 23)            ## авто-выводится из Tiles
var entries := {}                       ## id входа -> позиция

@onready var _tiles: TileMapLayer = $Tiles

func _ready() -> void:
	_make_parallax()
	var r := _tiles.get_used_rect()
	size = r.end                        # правый-нижний угол (в тайлах)
	for n in find_children("*", "Entry", true, false):
		entries[n.id] = n.position

# ── Атмосфера ────────────────────────────────────────────────────────────────

func _make_parallax() -> void:
	var pb := ParallaxBackground.new()
	pb.layer = -1
	add_child(pb)

	var far := ParallaxLayer.new()
	far.motion_scale = Vector2(0.15, 0.15)
	pb.add_child(far)

	var base := ColorRect.new()
	base.color = Palette.CH1_FG.lerp(Palette.CH1_MID, 0.3)
	base.size = Vector2(6000, 3600)
	base.position = Vector2(-2200, -1400)
	far.add_child(base)

	var fog := Sprite2D.new()
	fog.texture = _fog_tex()
	fog.centered = false
	fog.position = Vector2(-800, -300)
	fog.scale = Vector2(60, 8)
	far.add_child(fog)

	if beacon != Vector2.ZERO:
		var b := Sprite2D.new()
		b.texture = load("res://assets/vfx/kenney_particles/circle_05.png")
		b.position = beacon
		b.scale = Vector2(1.4, 1.4)
		b.modulate = Palette.AMBER_LIGHT
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		b.material = m
		far.add_child(b)

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
