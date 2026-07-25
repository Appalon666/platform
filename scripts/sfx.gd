extends Node
## Процедурный синтез звука — НИКАКИХ внешних файлов. Всё считается кодом при старте:
## волна (square/saw/sine) + шум + огибающая → AudioStreamWAV. Web-safe, вес ≈ 0.
## Автолоад «Sfx» (см. project.godot). Вызов: Sfx.play("jump").

const RATE := 22050

var _lib := {}
var _players: Array[AudioStreamPlayer] = []
var _idx := 0

func _ready() -> void:
	# --- Банк звуков. Крути параметры — это и есть «настроить звук» ---
	# _tone(длит, f_старт, f_конец, форма, доля_шума, спад_огибающей)
	_lib["jump"]       = _tone(0.12, 340, 640, "square", 0.05, 2.2)
	_lib["walljump"]   = _tone(0.11, 300, 520, "square", 0.10, 2.2)
	_lib["dash"]       = _tone(0.20, 720, 160, "saw",    0.55, 1.4)
	_lib["land"]       = _tone(0.09, 190,  80, "sine",   0.25, 2.6)
	_lib["death"]      = _tone(0.42, 440,  55, "square", 0.35, 1.1)
	_lib["checkpoint"] = _tone(0.36, 523, 784, "sine",   0.00, 0.8)   # тёплый подъём = уголёк ожил

	# Пул плееров, чтобы звуки могли накладываться (round-robin).
	for i in 6:
		var p := AudioStreamPlayer.new()
		p.volume_db = -8.0
		add_child(p)
		_players.append(p)

func play(name: String, pitch := 1.0) -> void:
	if not _lib.has(name):
		return
	var p := _players[_idx]
	_idx = (_idx + 1) % _players.size()
	p.stream = _lib[name]
	p.pitch_scale = pitch * randf_range(0.96, 1.04)   # лёгкий разброс — не приедается
	p.play()

## Синтез одного звука в 16-битный моно-WAV.
func _tone(dur: float, f_start: float, f_end: float, kind: String, noise_mix: float, decay: float) -> AudioStreamWAV:
	var count := int(dur * RATE)
	var data := PackedByteArray()
	data.resize(count * 2)
	var phase := 0.0
	for i in count:
		var t := float(i) / count                       # прогресс 0..1
		var freq := lerpf(f_start, f_end, t)
		phase += TAU * freq / RATE
		var w := 0.0
		match kind:
			"sine":   w = sin(phase)
			"square": w = 1.0 if sin(phase) >= 0.0 else -1.0
			"saw":    w = fmod(phase / TAU, 1.0) * 2.0 - 1.0
		var n := randf() * 2.0 - 1.0                     # белый шум
		var s := lerpf(w, n, noise_mix)
		var env := pow(1.0 - t, decay)                   # затухание громкости
		data.encode_s16(i * 2, int(clampf(s * env, -1.0, 1.0) * 32767 * 0.7))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	return wav
