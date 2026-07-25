extends Node2D
## Мир: держит игрока и текущую комнату, свапает комнаты при выходе через дверь.
## Каждая комната задаёт свой `size` (границы камеры) и `entries` (точки спавна).

const ROOMS := {
	"room1": "res://scripts/room1.gd",
	"room2": "res://scripts/room2.gd",
}

@onready var _player: CharacterBody2D = $Player
var _room: Room

func _ready() -> void:
	go_to("room1", "start")

## Сменить комнату: убрать старую, собрать новую, поставить игрока у нужной двери.
func go_to(name: String, entry: String) -> void:
	if not ROOMS.has(name):
		push_error("World: нет комнаты «%s»" % name)
		return
	if _room:
		_room.queue_free()
	_room = load(ROOMS[name]).new()
	add_child(_room)
	_room.exit_taken.connect(_on_exit)
	var pos: Vector2 = _room.entries.get(entry, Vector2(100, 620))
	_player.arrive(pos)
	_set_camera_limits(_room.size)

func _on_exit(target: String, entry: String) -> void:
	call_deferred("go_to", target, entry)   # свап после текущего кадра физики

## Камера живёт на игроке; лимиты — по размеру текущей комнаты (в тайлах × 32).
func _set_camera_limits(sz: Vector2i) -> void:
	var cam := _player.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		return
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = sz.x * 32
	cam.limit_bottom = sz.y * 32
