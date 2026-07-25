extends Control
## Главное меню — атмосферный экран в духе мира: холодный туман, тёплый янтарный маяк,
## дрейфующие угольки. «Продолжить» (если есть сейв) / «Новая игра» / «Выход».
## Стартовая сцена проекта (project.godot → run/main_scene).

const GAME := "res://scenes/main.tscn"

var _beacon: TextureRect
var _t := 0.0

func _ready() -> void:
	var vp := get_viewport_rect().size
	_bg(vp)
	_embers(vp)
	_beacon_glow(vp)
	_vignette(vp)
	_content(vp)
	# плавное появление
	modulate = Color(1, 1, 1, 0)
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.8).set_trans(Tween.TRANS_SINE)

func _process(delta: float) -> void:
	_t += delta
	if _beacon != null:
		var pulse := 0.5 + 0.5 * sin(_t * 1.1)
		_beacon.modulate.a = 0.30 + 0.16 * pulse
		var s := 1.0 + 0.05 * pulse
		_beacon.scale = Vector2(s, s)

# ── Слои ─────────────────────────────────────────────────────────────────────

func _bg(vp: Vector2) -> void:
	var tr := TextureRect.new()
	tr.texture = _vgrad(Palette.CH1_FG, Palette.CH1_FG.lerp(Palette.CH1_MID, 0.35))
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(tr)

func _embers(vp: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.position = Vector2(vp.x * 0.5, vp.y + 20.0)
	p.amount = 40
	p.lifetime = 7.0
	p.preprocess = 7.0
	p.lifetime_randomness = 0.4
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(vp.x * 0.5, 8.0)
	p.direction = Vector2(0, -1)
	p.spread = 12.0
	p.gravity = Vector2(0, -6.0)
	p.initial_velocity_min = 12.0
	p.initial_velocity_max = 34.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.6
	p.color = Color(Palette.AMBER_CORE, 0.5)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	p.material = mat
	add_child(p)

func _beacon_glow(vp: Vector2) -> void:
	_beacon = TextureRect.new()
	_beacon.texture = _rgrad(Color(Palette.AMBER_LIGHT, 0.55), Color(Palette.AMBER_LIGHT, 0.0))
	_beacon.custom_minimum_size = Vector2(760, 760)
	_beacon.size = Vector2(760, 760)
	_beacon.pivot_offset = Vector2(380, 380)
	_beacon.position = Vector2(vp.x * 0.5 - 380, vp.y * 0.5 - 380)
	_beacon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_beacon.material = mat
	_beacon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_beacon)

func _vignette(vp: Vector2) -> void:
	var tr := TextureRect.new()
	tr.texture = _rgrad(Color(0, 0, 0, 0), Color(Palette.CH1_FG, 0.7), 0.5)
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tr)

func _content(vp: Vector2) -> void:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)

	var title := Label.new()
	title.text = "PRECISION MV"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 60)
	title.add_theme_color_override("font_color", Palette.AMBER_LIGHT)
	title.add_theme_color_override("font_shadow_color", Color(Palette.AMBER_DEEP, 0.5))
	title.add_theme_constant_override("shadow_offset_x", 0)
	title.add_theme_constant_override("shadow_offset_y", 3)
	title.add_theme_constant_override("shadow_outline_size", 8)
	box.add_child(title)

	var sub := Label.new()
	sub.text = "тихий странник · дорога домой"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 17)
	sub.add_theme_color_override("font_color", Palette.CH1_FOG)
	box.add_child(sub)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 34)
	box.add_child(gap)

	if Progress.has_save():
		_button(box, "Продолжить", _on_continue)
	_button(box, "Новая игра", _on_new_game)
	_button(box, "Выход", _on_quit)

# ── Кнопки ───────────────────────────────────────────────────────────────────

func _button(box: VBoxContainer, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 54)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 25)
	b.focus_mode = Control.FOCUS_NONE

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(Palette.CH1_MID, 0.10)
	normal.set_corner_radius_all(7)
	normal.border_width_bottom = 2
	normal.border_color = Color(Palette.CH1_MID, 0.5)
	_pad(normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(Palette.AMBER_CORE, 0.16)
	hover.set_corner_radius_all(7)
	hover.border_width_bottom = 2
	hover.border_color = Color(Palette.AMBER_LIGHT, 0.7)
	_pad(hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(Palette.AMBER_CORE, 0.28)
	pressed.set_corner_radius_all(7)
	_pad(pressed)

	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_color_override("font_color", Color("d8cfc4"))
	b.add_theme_color_override("font_hover_color", Palette.AMBER_LIGHT)
	b.add_theme_color_override("font_pressed_color", Palette.AMBER_CORE)
	b.pressed.connect(cb)
	box.add_child(b)

func _pad(sb: StyleBoxFlat) -> void:
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10

# ── Градиент-текстуры ────────────────────────────────────────────────────────

func _vgrad(top: Color, bottom: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([top, bottom])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 8
	t.height = 256
	t.fill = GradientTexture2D.FILL_LINEAR
	t.fill_from = Vector2(0, 0)
	t.fill_to = Vector2(0, 1)
	return t

func _rgrad(inner: Color, outer: Color, mid: float = 0.0) -> GradientTexture2D:
	var g := Gradient.new()
	if mid > 0.0:
		g.offsets = PackedFloat32Array([0.0, mid, 1.0])
		g.colors = PackedColorArray([inner, inner, outer])
	else:
		g.offsets = PackedFloat32Array([0.0, 1.0])
		g.colors = PackedColorArray([inner, outer])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 256
	t.height = 256
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	return t

# ── Действия ─────────────────────────────────────────────────────────────────

func _on_continue() -> void:
	Progress.load_game()
	get_tree().change_scene_to_file(GAME)

func _on_new_game() -> void:
	Progress.reset()
	get_tree().change_scene_to_file(GAME)

func _on_quit() -> void:
	get_tree().quit()
