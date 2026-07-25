# Level-Art Prompts — генерация уровней (Глава 1+)

Структурный стиль (по референсам): **срез-карта связанной локации** — сеть камер в
разрезе, руинная архитектура, холодный сине-серый туман слоями, чёрные силуэт-платформы
с тонкой кромкой, свисающие лозы; единственный тёплый акцент — **янтарь** (факелы-маяки,
руны, уголёк на фигурках, метки S/V). Для генераторов картинок (Midjourney / SD / DALL·E).

## 🧬 СТИЛЬ-ДНК (в начало каждого промта)

```
2D metroidvania level cutaway, side-scrolling cross-section map of interconnected
chambers, hand-painted flat silhouette art like Hollow Knight, Limbo and Inside.
Layered atmospheric fog with pale ruined structures fading into depth; black
foreground silhouettes with a thin cold rim-light on every platform edge; hanging
vines and roots; ancient ruined architecture. Desaturated cold blue-grey palette —
the ONLY warm saturated color is amber: torches, glowing runes, a distant beacon,
tiny ember-lit figures. Silent, melancholic, ancient, foggy. Readable platforming:
ledges, climbable walls, stairs, passages; a small "S" start torch and a distant
shrine exit. Muted greys #AEB7BE #5A6570 #14181C, amber accents #F2A65A #FFD08A.
```

## 🎲 Уникальные мотивы (добавляй ОДИН после ДНК)

1. **Храм-хаб** — `a grand collapsed temple hall at the center with passages radiating outward, a huge amber beacon-altar as the warm heart, tall broken columns, a bas-relief tower fading in the fog.`
2. **Бездонная шахта** — `tall vertical composition, a bottomless shaft descending into black, ledges spiralling down, a single amber ember glowing far at the bottom. --ar 9:16`
3. **Затопленные цистерны** — `a flooded drowned cistern, still black water with faint reflections, half-submerged arches, mist over the surface, one amber lantern on a floating slab, dripping.`
4. **Корневая пещера** — `giant petrified tree-roots weaving through ruined masonry, natural cave merged with stone, vines to climb, amber bio-luminescent fungus, a hidden shrine deep inside.`
5. **Оссуарий** — `bone-and-stone catacombs, skull motifs carved in walls, narrow crypt passages, candle-amber light, a reliquary glowing at the far end.`
6. **Обрыв Окраины** — `open windswept cliff-edge ruins, broken battlements over a foggy void, rolling mist, a distant amber beacon on a far tower — wide horizontal layout, more open sky.`
7. **Мёрзлые руины** — `frozen ruins, ice over old stone, frozen waterfalls, brittle cold cyan-grey, a warm amber ember trapped inside ice. base palette cold green-grey #7E8C8A #38443F.`
8. **Забытый механизм** — `rusted ancient gears half-buried in stone ruins, mechanical tilting platforms, an amber pilot-flame in the machinery, industrial-ancient depths.`

## 🚫 Negative + параметры

```
bright colors, saturated, cartoon, cluttered busy texture, detailed surfaces, UI, text,
watermark, faces, neon, daylight, cheerful, modern
```
`--ar 16:9` (горизонт) / `--ar 9:16` (вертикаль) · `--style raw`

## 🔁 Чтобы не повторялись
- Меняй мотив (главный источник уникальности) + сид + позицию янтарного фокуса.
- Сдвигай холодную базу по главам: Окраина `#5A6570` → Поселение `#6B6357` → Глубины `#38443F`.
- Варьируй доминанту компоновки: вертикаль / горизонталь / радиальный хаб / спуск.
