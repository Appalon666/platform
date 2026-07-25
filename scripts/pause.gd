extends CanvasLayer
## Пауза по Esc: останавливает мир и показывает меню. Строит UI в коде.
## Работает во время паузы (process_mode = ALWAYS). Добавь как узел PauseMenu в main.tscn.

var _panel: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_build()
	_panel.visible = false

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("pause"):
		_toggle()
		get_viewport().set_input_as_handled()

func _toggle() -> void:
	var p := not get_tree().paused
	get_tree().paused = p
	_panel.visible = p

func _build() -> void:
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.05, 0.74)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(dim)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	_panel.add_child(box)

	var title := Label.new()
	title.text = "ПАУЗА"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Palette.AMBER_LIGHT)
	box.add_child(title)

	_add_button(box, "Продолжить", _toggle)
	_add_button(box, "Рестарт комнаты", _on_restart)
	_add_button(box, "В главное меню", _on_menu)

func _add_button(box: VBoxContainer, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 52)
	b.add_theme_font_size_override("font_size", 26)
	b.pressed.connect(cb)
	box.add_child(b)

func _on_restart() -> void:
	_toggle()
	var w := get_tree().get_first_node_in_group("world")
	if w != null:
		w.go_to(Progress.last_room, Progress.last_entry)

func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
