extends Marker2D
class_name Entry
## Точка спавна. World ставит игрока сюда, придя через дверь с этим id.
## Перетащи Entry.tscn в комнату, задай id (напр. "start", "from_west").

@export var id: String = "start"
