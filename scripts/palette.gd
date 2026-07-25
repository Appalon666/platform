extends Node
## Единый источник цвета — по ARTBIBLE.md §2. ВСЁ в игре берёт цвета отсюда.
## Ось: застыло → выцветший холодный нейтраль; движется/живо → янтарь.
## Автолоад «Palette» (см. project.godot). Обращение: Palette.AMBER_LIGHT и т.д.

# --- Цвет жизни (сквозной для всех глав) ---
const AMBER_CORE  := Color("f2a65a")   ## основной янтарь
const AMBER_LIGHT := Color("ffd08a")   ## свечение, маяк, уголёк
const AMBER_DEEP  := Color("b9713b")   ## тёплая тень

# --- Глава 1 — Окраина (бледный сине-серый) ---
const CH1_FOG := Color("aeb7be")       ## дальний туман / небо
const CH1_MID := Color("5a6570")       ## игровой силуэт (платформы)
const CH1_FG  := Color("14181c")       ## передний план / глубокая тень

# --- Глава 2 — Поселение (пыльно-пепельный) ---
const CH2_FOG := Color("b8ada0")
const CH2_MID := Color("6b6357")
const CH2_FG  := Color("191712")

# --- Глава 3 — Глубины (холодный тёмно-зелёно-серый) ---
const CH3_FOG := Color("7e8c8a")
const CH3_MID := Color("38443f")
const CH3_FG  := Color("0e1413")

## Базы по главам одним обращением: Palette.chapter(1).mid и т.п.
func chapter(n: int) -> Dictionary:
	match n:
		1: return {"fog": CH1_FOG, "mid": CH1_MID, "fg": CH1_FG}
		2: return {"fog": CH2_FOG, "mid": CH2_MID, "fg": CH2_FG}
		3: return {"fog": CH3_FOG, "mid": CH3_MID, "fg": CH3_FG}
		_: return {"fog": CH1_FOG, "mid": CH1_MID, "fg": CH1_FG}
