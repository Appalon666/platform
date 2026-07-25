extends Node
## Фоновая музыка биома. Треки Hollow Melodies не зациклены (сделаны на fade in/out),
## поэтому играем их плейлистом: трек доиграл → плавно вводим следующий (перемешано).
## Автолоад «Music» (см. project.godot). Управление: Music.play() / Music.stop().

@export var target_db := -8.0        ## Рабочая громкость музыки
@export var fade := 2.5              ## Длительность плавного ввода трека (сек)
const DIR := "res://assets/audio/music/"

var _player: AudioStreamPlayer
var _tracks: Array[AudioStream] = []
var _order: Array = []
var _pos := 0

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	_player.volume_db = target_db
	add_child(_player)
	_player.finished.connect(_advance)
	_load()
	play()

func _load() -> void:
	if not DirAccess.dir_exists_absolute(DIR):
		return
	for f in DirAccess.get_files_at(DIR):
		# .import — сайдкар редактора; в сборке остаётся только .wav/.ogg
		if f.ends_with(".wav") or f.ends_with(".ogg"):
			var s := load(DIR + f) as AudioStream
			if s != null:
				_tracks.append(s)
	_reshuffle()

func _reshuffle() -> void:
	_order = range(_tracks.size())
	_order.shuffle()
	_pos = 0

## Запустить музыку с текущего места плейлиста (с плавным вводом).
func play() -> void:
	if _tracks.is_empty():
		return
	_player.stream = _tracks[_order[_pos]]
	_player.play()
	_fade_in()

## Плавно приглушить и остановить.
func stop() -> void:
	var tw := create_tween()
	tw.tween_property(_player, "volume_db", -40.0, fade)
	tw.tween_callback(_player.stop)

func _advance() -> void:
	_pos += 1
	if _pos >= _order.size():
		_reshuffle()           # прошли весь плейлист — тасуем заново
	play()

func _fade_in() -> void:
	_player.volume_db = -40.0
	create_tween().tween_property(_player, "volume_db", target_db, fade)
