# Credits & Asset Licenses

Учёт всех сторонних ассетов: источник, автор, лицензия. Заполняем по мере добавления —
на релизе (Steam/Яндекс) это экономит часы разбирательств. CC0 = кредит не обязателен,
но мы всё равно благодарим авторов здесь.

## Аудио

### Kenney — Interface Sounds + UI Audio
- **Файлы:** `assets/audio/kenney/interface/` (100 шт.), `assets/audio/kenney/ui/` (51 шт.)
- **Автор:** Kenney — https://kenney.nl
- **Лицензия:** **CC0 1.0** (Public Domain) — свободно для личных, учебных и коммерческих проектов, атрибуция не обязательна. См. `LICENSE.txt` в каждой папке.
- **Использование:** UI / меню (клики, подтверждения, переключатели, ошибки, скролл).
- **Назначение:** Фаза 2 (меню/пауза) и далее.

### Эмбиент окружения (Freesound, все CC0)
- **Файлы:** `assets/audio/ambience/`
  - `hollow_wind.wav` — «SYT hollow wind 2» by **CAT-FOX_ALEX**, Freesound #863820 (исходник .flac → сконвертирован в .wav). Эмбиент Гл.1.
  - `dark_drone.wav` — «dark texture with glitches, wind, voices, drone» by **bassimat**, Freesound #863952.
  - `forest_rain.wav` — «forest rain atmo fantasy» by **szegvari**, Freesound #577975.
- **Лицензия:** **CC0 1.0** (Public Domain) — коммерция ОК, атрибуция не обязательна.
- **Использование:** фоновая петля-подложка биома, `scripts/ambience.gd` (Гл.1 = hollow_wind).

### Процедурные звуки движения (собственные)
- **Файлы:** генерируются в коде — `scripts/sfx.gd` (jump / walljump / dash / land / death / checkpoint).
- **Лицензия:** наши, без ограничений.

## Музыка

### Hollow Melodies Lite (Tom Feldmann)
- **Файлы:** `assets/audio/music/Adventure{2,4,6,10,11}.wav` (5 треков, ~2:30 каждый)
- **Автор:** Tom Feldmann — https://tomfeldmann.itch.io/hollow-melodies-lite-free-metroidvania-music-pack
- **Лицензия:** **CC BY 4.0** — коммерция разрешена, **атрибуция ОБЯЗАТЕЛЬНА**.
- **⚠️ ТРЕБУЕТСЯ КРЕДИТ В ТИТРАХ ИГРЫ:** «Music: Tom Feldmann (Hollow Melodies) — CC BY 4.0».
- **Использование:** фоновая музыка биома (Глава 1), плейлист в `scripts/music.gd`.

Кандидаты на будущее:
- **Hollow Melodies Full** — 30 треков, **CC0** (кредит не нужен), платно.
- **Freesound.org** (фильтр License = CC0) — эмбиент окружения: ветер, капли, гул.
- **Pixabay Music** — Pixabay License (коммерция ОК, без атрибуции).

> ⚠️ При добавлении CC BY-ассета — обязательно вписать автора сюда И вывести в титрах игры.

## TODO по релизу
- [ ] Экран титров с кредитами (обязателен из-за CC BY музыки).
- [ ] Для web-сборки (Яндекс, Фаза 7): сконвертировать музыку `.wav → .ogg` (сейчас ~25 МБ/трек).
