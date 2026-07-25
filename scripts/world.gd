extends Node2D
## Мир: держит игрока и текущую комнату (.tscn), свапает комнаты по вызову двери.
## Двери находят World по группе "world" и зовут go_to(target, entry).

const ROOMS := {
	"room1": "res://scenes/rooms/room1.tscn",
	"room2": "res://scenes/rooms/room2.tscn",
	"room3": "res://scenes/rooms/room3.tscn",
	"room4": "res://scenes/rooms/room4.tscn",
	"room5": "res://scenes/rooms/room5.tscn",
	"room6": "res://scenes/rooms/room6.tscn",
	"room7": "res://scenes/rooms/room7.tscn",
}

@onready var _player: CharacterBody2D = $Player
var _room: Node

func _ready() -> void:
	add_to_group("world")
	go_to(Progress.last_room, Progress.last_entry)      # старт с сейва (или room1/start для новой игры)
	if Progress.has_ability("double_jump"):             # вернуть открытые способности
		_player.unlock_double_jump()

## Сменить комнату: убрать старую, инстансить новую, поставить игрока у нужной двери.
func go_to(name: String, entry: String) -> void:
	if not ROOMS.has(name):
		push_error("World: нет комнаты «%s»" % name)
		return
	if _room:
		_room.queue_free()
	_room = load(ROOMS[name]).instantiate()
	add_child(_room)
	var pos: Vector2 = _room.entries.get(entry, Vector2(100, 620))
	_player.arrive(pos)
	_player.set_kill_y(_room.size.y * 32 + 240)   # бездна ниже пола комнаты
	_set_camera_limits(_room.size)
	Progress.mark_room(name, entry)               # автосейв точки «Продолжить»

## Камера живёт на игроке; лимиты — по размеру текущей комнаты (в тайлах × 32).
func _set_camera_limits(sz: Vector2i) -> void:
	var cam := _player.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		return
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = sz.x * 32
	cam.limit_bottom = sz.y * 32
