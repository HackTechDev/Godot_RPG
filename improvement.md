# Improvements — Commando Zombi RPG v4

Améliorations apportées à des fonctionnalités existantes.

---

## Détection de partie du corps — recalibration pixel-précise

**Problème initial :** les seuils verticaux de `_body_part_at()` utilisaient des offsets fixes en pixels (`-20, -2, +8, +20`) issus d'estimations, sans tenir compte des dimensions réelles du sprite ni du transform complet de l'entité.

**Améliorations apportées :**

- Remplacement de `world_pos - entity.global_position` par `entity.global_transform.affine_inverse() * world_pos` : gère la rotation, l'échelle et la translation de l'entité
- Lecture des dimensions exactes du frame via `spr.texture.get_size() / hframes / vframes` et prise en compte de `spr.scale`
- Analyse pixel du frame LPC 64×64 (`idle_down`, frame 130) pour calibrer les seuils réels :

| Zone | Lignes frame | ly local | Observation pixel |
|---|---|---|---|
| Tête | 13–31 | `ly < 0` | Largeur ≤ 22 px |
| Torse | 32–41 | `0 ≤ ly < +10` | Saut à 26–30 px : épaules |
| Mains | 42–51 | `+10 ≤ ly < +20` | Avant-bras + mains |
| Jambes | 52–57 | `+20 ≤ ly < +26` | Largeur chute à 12–14 px |
| Pieds | 58–61 | `ly ≥ +26` | |

- Bras détectés dans la bande `0 à +20` si `|lx| > frame_w * 0.17` (~11 px hors torse central)
- La limite Tête / Torse démarre désormais exactement au niveau du haut des bras (épaules, `ly = 0`)

**Fichiers :** `Scenes/Player/player.gd`

---

## Sauvegarde des PNJ — robustesse multi-callsite

**Problème initial :** trois appelants de `liblevel.saveAllObjects()` (`player.gd`, `base_level.gd`, `main_menu.gd`) ne passaient pas la liste des PNJ, ce qui écrasait `npcs.json` avec un tableau vide.

**Améliorations apportées :**

- Signature de `saveAllObjects()` étendue avec le paramètre `npcs = []`
- Les trois callsites passent désormais `get_tree().get_nodes_in_group("npc")`
- `reinitializeLevel()` inclut `"npcs.json"` dans la liste des fichiers à supprimer
- Vérification null-safe sur `FileAccess.open()` avant écriture de `npcs.json`

**Fichiers :** `Lib/liblevel.gd`, `Scenes/Player/player.gd`, `Scenes/Levels/base_level.gd`, `UI/main_menu.gd`

---

## Chargement des PNJ — application de l'état mort

**Problème initial :** `apply_dead_state()` était appelé depuis `_load_npcs()` via `call_deferred`, avant que les nœuds `@onready` (`name_label`, `interaction_label`) ne soient disponibles.

**Amélioration apportée :**

- L'appel à `apply_dead_state()` est déplacé dans `npc.setup()`, qui est exécuté après `add_child()` — les `@onready` sont donc résolus
- `setup()` lit `config.get("dead", false)` et `config.get("death_rotation", PI/2)` et appelle `apply_dead_state()` directement

**Fichiers :** `Objects/NPC/npc.gd`, `Scenes/Levels/base_level.gd`

---

## Mode d'affichage — passage en mode fenêtré

**Contexte :** le projet était configuré en plein écran sans bordures (`window/size/mode=3`) ce qui gênait le développement.

**Amélioration apportée :**

- `window/size/mode=0` (fenêtré) dans `project.godot`
- Viewport 1280×720 conservé
- `window/stretch/mode="canvas_items"` + `window/stretch/scale_mode="integer"` : pas de flou, mise à l'échelle entière

**Fichiers :** `project.godot`

---

## Option de debug — visibilité de la ligne de tir

**Contexte :** la ligne rouge entre le joueur et la cible pouvait gêner en cas de test.

**Amélioration apportée :**

- Case à cocher **"Afficher la ligne rouge de la cible"** dans **Settings → Debug**
- Contrôlée par `GameConfig.show_aim_line` (autoload), persistée dans `user://settings.json`
- Appliquée en temps réel dans `_CrosshairDraw._draw()` : `if line_visible and GameConfig.show_aim_line:`

**Fichiers :** `Autoload/game_config.gd`, `UI/main_menu.tscn`, `UI/main_menu.gd`, `Scenes/Player/player.gd`
