# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Commando Zombi RPG** — a 2D top-down RPG built with Godot 4.6, authored by "Le Sanglier des Ardennes". Playable in browser at https://projet.hacktech.dev/rpg_godot/rpg.html.

## Common Commands

No Godot binary is installed locally — all in-editor work is done inside Godot itself. CLI scripts below are Python/bash tools committed to the repo.

**Procedural level generation (Python, no Godot needed):**
```bash
# Generate one ASCII map (output: Scripts/level_001.txt + .json)
python3 Scripts/generate_level.py --output Scripts/level_001 --seed 42

# Build Godot scene files from ASCII maps (levels 5–10 by default)
python3 Scripts/build_levels.py          # all configured levels
python3 Scripts/build_levels.py 7 9      # specific levels only
```

**Reset save data during development (Linux):**
```bash
# Delete a specific level's cached save to force res:// defaults
rm -r ~/.local/share/godot/app_userdata/rpg_v4/level_1/

# Full reset (all levels) — or use the in-game "Réinitialiser" button
```

**Export (requires Godot binary in PATH):**
```bash
godot --headless --export-release "Web" ../RPG/rpg.html
godot --headless --export-release "Linux/X11" ../CommandoZombiRPG_linux_g4/rpg_godot_v1.x86_64
```

**Git workflow:**
```bash
bash gitPush.sh   # pushes to current branch
```
Commit format: `type(scope): description` with body. Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `style`.

## Architecture

### Autoloads (all registered in project.godot)

| Singleton | File | Role |
|-----------|------|------|
| `EventBus` | `Autoload/EventBus.gd` | Cross-system signals (see below) |
| `Player_data` | `Scenes/Player/player_data.gd` | All runtime player state (static vars) |
| `Player_data_default` | `Scenes/Player/player_data_default.gd` | Default spawn values |
| `GameConfig` | `Autoload/game_config.gd` | Debug flags, speed, SFX settings |
| `PlayerConfig` | `Autoload/player_config.gd` | LPC sprite inset constants |
| `SceneTransition` | `Autoload/scene_transition.gd` | Async scene loading with fade + progress bar |
| `SpriteLibrary` | `Autoload/sprite_library.gd` | LPC spritesheet key → Texture2D registry |
| `ArmoryData` | `Autoload/armory_data.gd` | Shop item catalogue |

**EventBus signals:**
- `build_computer(direction)` — place a Computer at player position
- `item_collected(text)` — show pickup notification
- `player_mounted_mecha(mecha)` / `player_dismounted_mecha()` — mecha state changes
- `level_map_ready(floor_cells: Array, map_scale: int)` — emitted by `base_level._emit_level_map()` (deferred) for the minimap

### Save System (`Lib/liblevel.gd`)

Two-tier priority per level — **user:// is read first, res:// is the fallback**:

| Priority | Path | Purpose |
|----------|------|---------|
| 1 | `user://level_N/objects.json` | Current session save |
| 1 | `user://level_N/enemies.json` | " |
| 1 | `user://level_N/mechas.json` | " |
| 2 | `res://Scenes/Levels/level_N/objects.json` | Project defaults |

- Player state → `user://rpg.json`
- Once a transition or menu-close triggers a save, the `user://` file permanently shadows `res://` until reset.
- `liblevel.saveAllObjects(scene, computers, robots, robot_enemies, mechas)` — serializes all live objects.
- Enable `GameConfig.DEBUG = true` in `Autoload/game_config.gd` to log which file path is being read.

### Level System

**Two distinct types of levels:**

**Native levels (1–3):** Hand-designed in the Godot editor. TileMap structure:
```
level_N (Node2D)
└── ground (TileMapLayer)         ← container
    ├── Dalle (TileMapLayer)      ← visible floor tiles
    └── Wall (TileMapLayer)       ← wall tiles with collision
```

**Generated levels (4–10):** Created by the Python pipeline and `Scripts/build_levels.py`. TileMap structure:
```
level_N (Node2D)
└── ground (TileMap)
    ├── layer_0                   ← floor tiles (GROUND_SRC=524288, TILE_GROUND=26)
    └── layer_1                   ← wall tiles (WALL_SRC=327680, TILE_WALL=31)
```
Each ASCII character in `Scripts/level_0NN.txt` maps to an 8×8 block of 16 px tiles = 128 px world-space per character. Convention: `#` = floor, `S` = spawn, `>` = exit, ` ` = void.

**`Scenes/Levels/base_level.gd`** — base class for all levels:
- Instantiates player, loads objects/enemies/NPCs/mechas from JSON.
- Level transitions via `level_connections.json` (JSON-based, **not** node-name encoding — see `Docs/level_transition_technical.md`).
- Transition trigger: player sprite rect overlaps a trigger zone → press **Space** → `_compute_arrival_spawn()` → `SceneTransition.change_scene()`.
- Emits `EventBus.level_map_ready` (deferred) for the minimap after player is ready.

**Adding a connection between two levels** — edit both `level_connections.json` files; the return trigger is mandatory for spawn calculation. See `Docs/level_transition_technical.md` for the exact JSON schema.

### Player (`Scenes/Player/player.gd`) — CharacterBody2D

- Speed: 70 px/s normal, 35 px/s slow (body ≠ look direction, or moving backward).
- **Left-click within 26 px of player sprite** opens the radial menu (pauses game).
- Body direction and look direction are independent; look can deviate up to ±45° from body.
- Updates `Player_data.player_pos_x/y` and `player_facing` every physics frame.
- Instantiates all UI as children in `_ready()`: HUD, radial menu, character sheet, armory, notification, game_over, combat_ui, dialogue_box, **minimap**.

**Radial menu items** (defined in `_radial_items()`):

| Letter | ID | Action |
|--------|-----|--------|
| B | `build` | Place Computer via EventBus |
| T | `take` | Collect `contact_object` |
| Z | `talk` | Open dialogue with `contact_npc` |
| C | `combat` | Start combat with `contact_enemy` |
| P | `sheet` | Toggle character sheet |
| A | `attack` | Attack in combat |
| M | `minimap` | Toggle minimap |

**LPC appearance system:** `SpriteLibrary` maps string keys to Texture2D. Player body is composed of `AppearanceLayers/Sprite*` nodes (Body, Legs, Feet, Torso, Arms, Bracers, Gloves, Head, Face, Hair, Headwear) — all synced to the same animation frame as `master_sprite`.

**Mecha system:** `M` key mounts/dismounts the nearest `Mecha` node within 50 px. While mounted, player collision is disabled and movement is delegated to the Mecha. State: `Player_data.in_mecha`, `Player_data.current_mecha_id`.

### Minimap (`UI/minimap.gd`)

CanvasLayer (layer=5), built programmatically in `_ready()`. Positioned bottom-right (200×100 px content area).

- Receives `EventBus.level_map_ready(floor_cells, map_scale)`.
- Maintains an `Image` + `ImageTexture` for efficient rendering (one draw call via `draw_texture()`).
- Fog of war: cells are painted to `COL_FLOOR_FOG` initially; revealed in a radius of 5 logical cells around the player and repainted to `COL_FLOOR_VIS` incrementally.
- Visited state in `Player_data.minimap_visited` (Dictionary), cleared on each new level.
- `map_scale`: 128 for generated levels (8 tiles × 16 px), 16 for native levels.
- Toggle: radial menu "M — Carte" calls `minimap.toggle()`. State persisted in `Player_data.minimap_enabled`.

### Procedural Generation Pipeline

```
generate_level.py            →  level_00N.txt + level_00N.json   (ASCII map)
Scripts/build_levels.py      →  Scenes/Levels/level_N/*.tscn/.gd/objects.json/...
missions.json                ←  scene path + spawn updated automatically
```

- `generate_level.py` accepts `--output` (basename) and `--seed` (int) CLI args.
- `build_levels.py` replicates `Scripts/generate_level.gd` (EditorScript) in pure Python. Run it from the project root. UIDs and node IDs are fixed per level in `LEVEL_CFGS`.
- `Scripts/generate_level.gd` can also be run inside Godot via **File › Run Script** to regenerate levels 5–10 in one pass.

### UI Architecture

All UI scenes extend `CanvasLayer`. The player instantiates them as children in `_ready()`:

| Scene | Purpose |
|-------|---------|
| `UI/hud.tscn` | Stats panel (health, computers, robots, zone, position), top bar buttons, clock |
| `UI/radial_menu.tscn` | Circular action menu, opened on left-click near player |
| `UI/minimap.tscn` | Fog-of-war minimap, bottom-right corner |
| `UI/character_sheet.tscn` | Player stats + appearance viewer |
| `UI/armory.tscn` | Shop — purchases call `ArmoryData`, deduct credits |
| `UI/combat_ui.tscn` | Dice-roll combat overlay (d10 system) |
| `UI/dialogue_box.tscn` | NPC dialogue with branching choices |
| `UI/notification.tscn` | Pickup/event toast |
| `UI/game_over.tscn` | Game over screen |
| `UI/main_menu.tscn` | Main menu; also used in-game (pause menu mode) |

### Missions (`missions.json`)

Root array of mission objects with `id`, `title`, `description`, `objectives`, `scene`, `spawn`, `start_datetime`, `sunrise`, `sunset`. The active mission's spawn and scene path are written by `build_levels.py` / `generate_level.gd` when levels are regenerated. `Player_data.current_mission_id` tracks the running mission.

## Input Actions (project.godot)

| Action | Key | Purpose |
|--------|-----|---------|
| `ui_pause` | Escape | Close radial menu / cancel combat |
| `ui_m` | M | Mount / dismount Mecha |
| `ui_b` | B | Build Computer (also in radial) |
| `ui_t` | T | Interact / collect contact object |
| `ui_z` | Z | Talk to contact NPC |
| `ui_c` | C | Start / flee combat |
| `ui_a` | A | Attack in combat |
| `ui_p` | P | Toggle character sheet |
| `ui_r` | R | Push contact object |
| `ui_space` | Space | Confirm level transition |
| Standard directions | Arrow / WASD | Movement |
| `ui_h` | H | Help |

## Key Files for Common Tasks

| Task | File(s) |
|------|---------|
| Add a new EventBus signal | `Autoload/EventBus.gd` |
| Change player stats or global state | `Scenes/Player/player_data.gd` |
| Tune debug flags or speeds | `Autoload/game_config.gd` |
| Add a radial menu action | `_radial_items()` + `_handle_radial_action()` in `player.gd` |
| Add a level transition | Both `level_connections.json` files; see `Docs/level_transition_technical.md` |
| Regenerate levels 5–10 | `python3 Scripts/build_levels.py` then open in Godot to re-import |
| Generate a new ASCII map | `python3 Scripts/generate_level.py --output Scripts/level_0NN --seed N` |
| Place objects in a level | Edit `res://Scenes/Levels/level_N/objects.json` then delete `user://level_N/` cache |
