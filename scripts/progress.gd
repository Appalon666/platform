extends Node
## Прогресс сбора янтарных мошек. Хранит собранные id, чтобы при перезаходе в комнату
## собранные не появлялись снова. Автолоад «Progress».

signal changed(count: int)

var _collected := {}

func collect(id: String) -> void:
	if id == "" or _collected.has(id):
		return
	_collected[id] = true
	changed.emit(count())

func is_collected(id: String) -> bool:
	return _collected.has(id)

func count() -> int:
	return _collected.size()
