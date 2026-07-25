extends Node
## Прогресс игры + сохранение на диск. Хранит собранные мошки, открытые способности и
## последнюю комнату (точку «Продолжить»). Автолоад «Progress». Пишет user://save.json.

signal changed(count: int)

const SAVE_PATH := "user://save.json"

var _collected := {}                 ## id собранной мошки -> true
var abilities := {}                  ## имя способности -> true (напр. "double_jump")
var last_room := "room1"             ## куда войти при «Продолжить»
var last_entry := "start"

# ── Мошки ────────────────────────────────────────────────────────────────────

func collect(id: String) -> void:
	if id == "" or _collected.has(id):
		return
	_collected[id] = true
	changed.emit(count())
	save_game()

func is_collected(id: String) -> bool:
	return _collected.has(id)

func count() -> int:
	return _collected.size()

# ── Способности ──────────────────────────────────────────────────────────────

func unlock(ability: String) -> void:
	abilities[ability] = true
	save_game()

func has_ability(ability: String) -> bool:
	return abilities.get(ability, false)

# ── Позиция в мире (автосейв при переходе между комнатами) ────────────────────

func mark_room(room: String, entry: String) -> void:
	last_room = room
	last_entry = entry
	save_game()

# ── Диск ─────────────────────────────────────────────────────────────────────

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
	var data := {
		"motes": _collected.keys(),
		"abilities": abilities.keys(),
		"room": last_room,
		"entry": last_entry,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()

func load_game() -> void:
	if not has_save():
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var txt := f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(txt)
	if typeof(data) != TYPE_DICTIONARY:
		return
	_collected.clear()
	for id in data.get("motes", []):
		_collected[id] = true
	abilities.clear()
	for a in data.get("abilities", []):
		abilities[a] = true
	last_room = data.get("room", "room1")
	last_entry = data.get("entry", "start")
	changed.emit(count())

func reset() -> void:
	_collected.clear()
	abilities.clear()
	last_room = "room1"
	last_entry = "start"
	changed.emit(count())
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
