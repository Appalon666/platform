extends CanvasLayer
## Счётчик собранных мошек в углу. Обновляется по сигналу Progress.

@onready var _label: Label = $Label

func _ready() -> void:
	Progress.changed.connect(_update)
	_update(Progress.count())

func _update(n: int) -> void:
	_label.text = "✦ %d" % n
