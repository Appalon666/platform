extends Node
## Регистрируем действия ввода в коде — надёжнее и понятнее, чем править InputMap руками.
## Позже сделаем перенастройку клавиш через UI, но для прототипа так удобнее.

func _enter_tree() -> void:
	_bind("move_left",  [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("move_up",    [KEY_W, KEY_UP])
	_bind("move_down",  [KEY_S, KEY_DOWN])
	_bind("jump",       [KEY_SPACE, KEY_C])
	_bind("dash",       [KEY_SHIFT, KEY_K, KEY_X])
	_bind("restart",    [KEY_R])

func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
