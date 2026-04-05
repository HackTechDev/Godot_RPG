# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Commando Zombi RPG** — a 2D top-down RPG built with Godot 4.6, authored by "Le Sanglier des Ardennes". Playable in browser at https://projet.hacktech.dev/rpg_godot/rpg.html.

## Common Commands

All game development happens inside the Godot editor. There is no CLI build tool — use Godot's export system directly or the configured export presets.

**Export from CLI (requires Godot binary in PATH):**
```bash
# Linux export
godot --headless --export-release "Linux/X11" ../CommandoZombiRPG_linux_g4/rpg_godot_v1.x86_64

# Web export
godot --headless --export-release "Web" ../RPG/rpg.html
```

**Reinitialize save data (Linux only, via main menu UI):**
The main menu exposes a "Reinitialize" button on Linux that copies defaults from `res://World/Default/` to `user://`.

**Git push script:**
```bash
bash gitPush.sh   # pushes to rpg_v2 branch
```

## Architecture

### Autoloads / Global State

- **`Autoload/EventBus.gd`** — Singleton. Currently exposes one signal: `build_computer(direction)`. All cross-system events should go through here.
- **`Scenes/Player/player_data.gd`** (`Player_data`) — Static global data class holding runtime player state: health, position, facing direction, spawnpoint, current/previous scene, and collected object counts.
- **`Scenes/Player/player_data_default.gd`** (`Player_data_default`) — Default starting values (scene: `level_01`, spawnpoint: 440,136).

### Save System

Implemented in **`Lib/liblevel.gd`**:
- Player state → `user://rpg.json`
- Level objects → `user://[scene_name].json` (e.g., `user://level_01.json`)
- Default templates live in `res://World/Default/` and are copied on reinitialize.
- `load_game()` reads save files and hands off to Godot's scene loader.
- `saveAllObjects(scene, computers, robots)` serializes positioned scene objects to JSON.

### Level System

- **`Scenes/Levels/base_level.gd`** — Base class for all levels. Handles player instantiation and spawnpoint placement.
- **`Scenes/Levels/level_01.gd`** — Extends base. Deserializes Computers and Robots from JSON on `_ready`. Subscribes to `EventBus.build_computer` to spawn new Computers at directional offsets from the player.
- **`Scenes/Levels/level_02–04.gd`** — Minimal subclasses of `base_level.gd`.
- **`Scenes/Levels/entrance_x_2.gd` / `entrance_y_2.gd`** — Area2D transition zones. On player body entry, save current state and do a deferred scene change with calculated spawnpoint offset.

### Player

**`Scenes/Player/player.gd`** — CharacterBody2D at 70 units/sec:
- Directional input maps to facing values: 2=down, 4=left, 6=right, 8=up.
- `M` key toggles the in-game menu overlay.
- `B` key emits `EventBus.build_computer(direction)`.
- AnimationTree blends idle/move states per direction.
- Footstep audio plays only while moving.

### Collectables

- **`Objects/Computers/computer.gd`** — Area2D; increments `Player_data.computer` and removes self on player collision.
- **`Objects/Robots/robot.gd`** — Area2D; increments `Player_data.robot` and removes self on player collision.

### UI

**`UI/main_menu.gd`** — CanvasLayer managing main menu, settings, and help panels. Calls `liblevel.load_game()` on Play. Saves all state on Quit. Window close button is suppressed (quit only via button).

## Input Actions (defined in project.godot)

| Action | Key | Purpose |
|--------|-----|---------|
| `ui_pause` | Escape | Pause |
| `ui_m` | M | Toggle in-game menu |
| `ui_h` | H | Help |
| `ui_d` | D | Direction/input mode |
| `ui_b` | B | Build (place Computer) |
| `ui_t` | T | Interact/Trade |
| Standard directions | Arrow/WASD | Movement |

## Pending Work (from todo.md)

- Inventory menu system (not yet implemented)
- Player position initialization improvements

## Workflow Git

Après chaque modification significative, fais un commit git avec :
- Un titre court et descriptif (format : `type(scope): description`)
  - Types valides : `feat`, `fix`, `refactor`, `docs`, `chore`, `style`
- Un corps de message détaillant les changements effectués

Exemple :
```
feat(auth): ajouter la validation du token JWT

- Ajout de la vérification de l'expiration du token
- Gestion des erreurs 401 avec message explicite
- Mise à jour des tests unitaires correspondants
```
