# Transition de niveau — Documentation technique

## Vue d'ensemble

Le système de transition de niveau permet au joueur de passer d'un niveau à un autre en entrant dans une zone de trigger et en appuyant sur **Espace**. La position d'arrivée est calculée automatiquement pour placer le joueur de façon cohérente dans le niveau de destination.

---

## Fichiers impliqués

| Fichier | Rôle |
|---|---|
| `Scenes/Levels/base_level.gd` | Logique de détection et de transition |
| `Scenes/Levels/<level>/level_connections.json` | Définition des zones de trigger |
| `Autoload/player_config.gd` | Constantes d'inset du sprite |
| `Autoload/game_config.gd` | Flags de debug |

---

## Format JSON — `level_connections.json`

Chaque niveau possède un fichier `level_connections.json` dans son dossier. Il définit les connexions vers d'autres niveaux.

```json
{
  "connections": [
    {
      "id": "level_1_vers_level_2",
      "trigger": { "x": 120, "y": 234, "w": 128, "h": 16 },
      "to": {
        "scene": "res://Scenes/Levels/level_2/level_2.tscn"
      }
    }
  ]
}
```

### Champs du trigger

| Champ | Type | Description |
|---|---|---|
| `x` | float | Position X du **centre** du trigger en coordonnées monde |
| `y` | float | Position Y du **centre** du trigger en coordonnées monde |
| `w` | float | Largeur du trigger en pixels |
| `h` | float | Hauteur du trigger en pixels |

### Orientation du trigger

- **Trigger horizontal** (`w >= h`) : passage par le haut ou le bas (ex. 128×16)
- **Trigger vertical** (`h > w`) : passage par la gauche ou la droite (ex. 16×128)

---

## Détection de la zone de trigger

### Rect du frame sprite (`sw`)

Le rect du frame complet est calculé en coordonnées monde à partir de la position globale du `Sprite2D` :

```gdscript
var local_rect: Rect2 = master_sprite.get_rect()
var sw := Rect2(master_sprite.global_position + local_rect.position, local_rect.size)
```

Pour un sprite LPC 64×64 centré, `get_rect()` retourne `Rect2(-32, -32, 64, 64)`, donc `sw` a sa position en haut à gauche à `(player.x - 32, player.y - 32)`.

### Rect de détection (`sw_detect`)

Les sprites LPC ont des pixels transparents sur les bords du frame. Le rect de détection est réduit via les insets définis dans `PlayerConfig` pour correspondre au personnage visible :

```gdscript
var sw_detect := Rect2(
    sw.position.x + PlayerConfig.SPRITE_LEFT_INSET,
    sw.position.y + PlayerConfig.SPRITE_TOP_INSET,
    sw.size.x - PlayerConfig.SPRITE_LEFT_INSET - PlayerConfig.SPRITE_RIGHT_INSET,
    sw.size.y - PlayerConfig.SPRITE_TOP_INSET  - PlayerConfig.SPRITE_BOTTOM_INSET
)
```

### Constantes d'inset (`Autoload/player_config.gd`)

| Constante | Valeur | Description |
|---|---|---|
| `SPRITE_TOP_INSET` | 10 px | Transparence en haut du frame LPC |
| `SPRITE_BOTTOM_INSET` | 0 px | Transparence en bas du frame LPC |
| `SPRITE_LEFT_INSET` | 14 px | Transparence à gauche du frame LPC |
| `SPRITE_RIGHT_INSET` | 14 px | Transparence à droite du frame LPC |

### Condition de détection

La transition est disponible dès que `sw_detect` chevauche le rect du trigger :

```gdscript
if sw_detect.intersects(trigger_rect):
    # hint visible, Espace possible
```

---

## Déclenchement de la transition

Quand le joueur appuie sur **Espace** (`ui_space`) et que `sw_detect` chevauche un trigger :

1. Calcul de l'offset du joueur par rapport au centre du trigger source :
   ```gdscript
   var offset := player.global_position - trigger_rect.get_center()
   ```

2. Sauvegarde de l'état complet (position, objets, ennemis, données joueur) via `_save_transition_state()`.

3. Calcul de la position d'arrivée via `_compute_arrival_spawn()`.

4. Déclenchement du changement de scène via `SceneTransition.change_scene(target)`.

---

## Calcul de la position d'arrivée

### Principe

L'axe perpendiculaire au sens de passage est inversé, l'axe parallèle est conservé :

| Direction d'entrée | Axe inversé | Résultat |
|---|---|---|
| Trigger horizontal (haut/bas) | Y | Entrer par le haut → arriver par le bas, et vice-versa |
| Trigger vertical (gauche/droite) | X | Entrer par la gauche → arriver par la droite, et vice-versa |

```gdscript
if src_horizontal:
    arrival_offset = Vector2(offset.x, -offset.y)
else:
    arrival_offset = Vector2(-offset.x, offset.y)
```

### Correction des insets

Parce que la détection utilise `sw_detect` (décalé vers le bas de `SPRITE_TOP_INSET / 2` par rapport au centre du frame), la position de spawn est corrigée pour que le sprite visible apparaisse correctement dans le trigger de destination :

```gdscript
if src_horizontal:
    spawn.y -= PlayerConfig.SPRITE_TOP_INSET
else:
    spawn.x -= (PlayerConfig.SPRITE_LEFT_INSET - PlayerConfig.SPRITE_RIGHT_INSET) / 2.0
```

### Fallback

Si aucun trigger retour n'est trouvé dans le JSON de destination, un warning est émis et l'offset brut est utilisé comme position de spawn.

---

## Cooldown anti-déclenchement immédiat

À l'arrivée dans un nouveau niveau, un cooldown de 0,5 seconde empêche la transition de se redéclencher immédiatement (le joueur spawn dans la zone de trigger) :

```gdscript
if Player_data.use_json_spawn:
    _transition_cooldown = true
    get_tree().create_timer(0.5).timeout.connect(
        func() -> void: _transition_cooldown = false
    )
```

---

## Placement du joueur à l'arrivée

`_place_player()` applique les priorités suivantes :

1. **JSON spawn** (`Player_data.use_json_spawn == true`) : position calculée par `_compute_arrival_spawn()` — utilisée après une transition.
2. **Position sauvegardée** : dernière position connue dans `Player_data`.

---

## Debug

Deux options sont disponibles dans **Settings → Debug** :

| Option | Variable | Effet |
|---|---|---|
| Affichage hitbox sprite | `GameConfig.debug_show_hitbox` | Carré bleu autour du frame sprite du joueur |
| Affichage debug collision | `GameConfig.debug_show_collision` | Label vert indiquant la zone de sortie active |

Le label de debug affiche :
- `Zone de sortie (haut)` — le sprite entre dans un trigger horizontal par le haut
- `Zone de sortie (bas)` — le sprite entre dans un trigger horizontal par le bas
- `Zone de sortie (gauche)` — le sprite entre dans un trigger vertical par la gauche
- `Zone de sortie (droite)` — le sprite entre dans un trigger vertical par la droite

Les triggers sont également visualisés par un rectangle orange semi-transparent (`Polygon2D`, couleur `Color(1.0, 0.6, 0.0, 0.35)`) toujours visible en jeu.

---

## Ajouter une connexion entre deux niveaux

1. Dans `Scenes/Levels/level_A/level_connections.json`, ajouter une connexion vers `level_B` :
   ```json
   {
     "id": "level_A_vers_level_B",
     "trigger": { "x": 300, "y": 500, "w": 128, "h": 16 },
     "to": { "scene": "res://Scenes/Levels/level_B/level_B.tscn" }
   }
   ```

2. Dans `Scenes/Levels/level_B/level_connections.json`, ajouter la connexion retour vers `level_A` :
   ```json
   {
     "id": "level_B_vers_level_A",
     "trigger": { "x": 300, "y": 50, "w": 128, "h": 16 },
     "to": { "scene": "res://Scenes/Levels/level_A/level_A.tscn" }
   }
   ```

Le trigger retour est obligatoire : il sert à `_compute_arrival_spawn()` pour calculer la position d'arrivée dans `level_B`.
