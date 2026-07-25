extends Node
## Фоновый эмбиент-слой (тихая петля под музыкой) — «дыхание» биома.
## Гл.1 «Окраина» = полый ветер. Беды лежат в assets/audio/ambience/ и грузятся по имени.
## Автолоад «Ambience». Управление: Ambience.play("hollow_wind") / Ambience.stop().

@export var target_db := -20.0       ## Тихо — это подложка, не передний план
@export var fade := 3.0
@export var default_bed := "hollow_wind"   ## Что играет на старте (эмбиент Гл.1)
const DIR := "res://assets/audio/ambience/"

var _player: AudioStreamPlayer
var _beds := {}
var _current := ""

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)
	_player.finished.connect(_loop)        # беды не зациклены — крутим руками
	_load()
	if default_bed != "":
		play(default_bed)

func _load() -> void:
	if not DirAccess.dir_exists_absolute(DIR):
		return
	for f in DirAccess.get_files_at(DIR):
		if f.ends_with(".wav") or f.ends_with(".ogg"):
			var s := load(DIR + f) as AudioStream
			if s != null:
				_beds[f.get_basename()] = s

## Сменить/запустить бед по имени файла без расширения (crossfade-in).
func play(bed: String) -> void:
	if not _beds.has(bed):
		push_warning("Ambience: нет беда «%s»" % bed)
		return
	_current = bed
	_player.stream = _beds[bed]
	_player.play()
	_fade_in()

func stop() -> void:
	_current = ""
	var tw := create_tween()
	tw.tween_property(_player, "volume_db", -40.0, fade)
	tw.tween_callback(_player.stop)

func _loop() -> void:
	if _current != "":
		_player.play()                     # бесшовный повтор того же беда

func _fade_in() -> void:
	_player.volume_db = -40.0
	create_tween().tween_property(_player, "volume_db", target_db, fade)
