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

---

## Page Vidéo — connexions signal branchées programmatiquement

**Problème initial :** les connexions ajoutées manuellement dans le `.tscn` pour les boutons Vidéo/Appliquer/Retour n'étaient pas prises en compte par Godot (scène potentiellement mise en cache avec l'ancien état du nœud `Video` qui était un `Label`).

**Amélioration apportée :**

- Suppression des 3 connexions du `.tscn`
- Branchement dans `_connect_video_settings()` appelé depuis `_ready()` avec `is_connected()` pour éviter les doublons — même pattern que les éléments UI créés dynamiquement

**Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`

---

## Page Vidéo — gestion de la limitation mode éditeur

**Problème initial :** `DisplayServer.window_set_mode(WINDOW_MODE_FULLSCREEN)` est refusé dans la fenêtre embarquée de l'éditeur Godot (`Embedded window only supports Windowed mode`) — le bouton "Appliquer" semblait sans effet.

**Amélioration apportée :**

- Détection via `OS.has_feature("editor")` : en mode éditeur, le changement de mode est sauté mais la préférence est quand même écrite dans `user://settings.json`
- `LabelHint` (orange) affiché sur le panel Vidéo en mode éditeur : *"Plein écran non disponible dans l'éditeur. Le réglage sera appliqué au lancement du jeu."*
- En build standalone, le bouton "Appliquer" fonctionne normalement

**Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`

---

## Armurerie — affichage image à hauteur fixe (TextureRect)

**Problème initial :** la zone d'affichage de la photo d'arme ne respectait pas la hauteur de 180 px définie par `custom_minimum_size`.

**Cause :**

- Premier essai (`expand_mode = 1` + `stretch_mode = 6`) : `EXPAND_IGNORE_SIZE` avec `STRETCH_KEEP_ASPECT_COVERED` affichait l'image à sa taille naturelle ou la recadrait sans respecter les contraintes de layout.
- Deuxième essai (`expand_mode = 0` + `stretch_mode = 5`) : `EXPAND_KEEP_SIZE` force la taille minimale du nœud à égaler la taille de la texture — une image 800×600 écrasait le `custom_minimum_size = (0, 180)`.

**Solution retenue :**

- `expand_mode = 1` (IGNORE_SIZE) : la taille de la texture n'influence pas le layout du nœud
- `stretch_mode = 5` (KEEP_ASPECT_CENTERED) : l'image est mise à l'échelle pour tenir dans les bornes du nœud en conservant son ratio, centrée
- `size_flags_vertical = 0` (SHRINK_BEGIN) : le nœud ne s'étire pas au-delà de son `custom_minimum_size`
- `custom_minimum_size = Vector2(0, 180)` : hauteur garantie à 180 px

**Fichiers :** `UI/armory.tscn`

---

## Création de personnage — variable `name` renommée en `entry`

**Problème initial :** warning GDScript `SHADOWED_VARIABLE_BASE_CLASS` sur `main_menu.gd:1276` — la variable locale `name` dans `_delete_dir_recursive()` masquait la propriété `Node.name`.

**Amélioration apportée :**

- Variable locale renommée `entry` dans la boucle `DirAccess` de `_delete_dir_recursive()`

**Fichiers :** `UI/main_menu.gd`
