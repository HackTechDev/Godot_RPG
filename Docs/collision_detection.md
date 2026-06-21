# Collision et détection — Joueur / Ennemi

## Collision physique (blocage de mouvement)

Les deux entités sont des `CharacterBody2D` avec un `CollisionShape2D` (rectangle).
Aucune `collision_layer` / `collision_mask` explicite n'est définie dans les `.tscn` → les
deux utilisent les valeurs Godot par défaut (layer 1, mask 1) et se bloquent mutuellement.

Le joueur appelle `move_and_slide()` (`player.gd:545, 588`) — Godot gère automatiquement
le glissement autour du corps de l'ennemi. Un ennemi statique (`follow_player = false`)
ne fait jamais appel à `move_and_slide()` (early return dans `robot_enemy.gd:64`) et agit
comme un mur fixe.

## Détection de proximité (sans Area2D)

Il n'y a **pas** de `Area2D` ni de signal `body_entered`. Tout est calculé manuellement
dans `_physics_process` de l'ennemi (`robot_enemy.gd:58`), à chaque frame physics :

| Condition | Effet |
|---|---|
| `dist <= DETECTION_RADIUS (120 px)` ET dans le cône | L'ennemi suit le joueur (`velocity = dir * SPEED`) |
| `dist <= COMBAT_RADIUS (70 px)` | `Player_data.contact_enemy = self` |
| `dist <= DAMAGE_RADIUS (30 px)` | `-1 HP` au joueur (cooldown 1,5 s) |
| `dist > COMBAT_RADIUS` | `contact_enemy = null` |

### Cône de vision (`robot_enemy.gd:121`)

```gdscript
func _in_cone(to_player: Vector2) -> bool:
    var facing_vec = Vector2(cos(deg_to_rad(facing_angle)), sin(deg_to_rad(facing_angle)))
    return to_player.normalized().dot(facing_vec) >= cos(deg_to_rad(CONE_FOV_HALF))
```

- `facing_angle` : direction du regard de l'ennemi (degrés, 0 = droite, -90 = haut).
  Valeur par défaut `-90.0`, configurable via `enemies.json`.
- `CONE_FOV_HALF = 60°` : demi-angle → cône total de 120°.
- `DETECTION_RADIUS = 120 px` : rayon maximal de détection.

Le cône est dessiné visuellement via `_draw()` (polygone rouge semi-transparent).

## Déclenchement du combat

Le combat ne démarre **pas** automatiquement au contact physique. Séquence :

1. L'ennemi passe `Player_data.contact_enemy = self` quand le joueur est dans le cône à
   moins de `COMBAT_RADIUS (70 px)`.
2. Le joueur appuie sur `C` → `player.gd` appelle `_start_combat(Player_data.contact_enemy)`.
3. Les dégâts automatiques (`DAMAGE_RADIUS = 30 px`) sont indépendants du combat formel :
   ils s'appliquent si le joueur reste collé à l'ennemi sans initier le combat.

## Résumé des rayons

```
  ┌── DETECTION_RADIUS = 120 px ──────────────────┐
  │    ┌── COMBAT_RADIUS = 70 px ───────────┐     │
  │    │    ┌── DAMAGE_RADIUS = 30 px ─┐    │     │
  │    │    │        [ENNEMI]          │    │     │
  │    │    └──────────────────────────┘    │     │
  │    └────────────────────────────────────┘     │
  └───────────────────────────────────────────────┘
```

## Fichiers concernés

| Fichier | Rôle |
|---|---|
| `Objects/RobotEnemy/robot_enemy.gd` | Détection, cône, dégâts auto, `contact_enemy` |
| `Objects/RobotEnemy/robot_enemy.tscn` | `CollisionShape2D` (rectangle, position Y+5) |
| `Scenes/Player/player.gd:545,588` | `move_and_slide()` côté joueur |
| `Scenes/Player/player_data.gd` | `contact_enemy` (référence partagée) |
| `Scenes/Levels/level_N/enemies.json` | `facing_angle`, `follow_player` par ennemi |
