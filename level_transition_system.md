# Système de transition de niveaux et de spawn

## 1. Nommage des nœuds d'entrée (convention clé)

Chaque zone de transition est une instance d'`entrance_x_2.tscn` (passage horizontal) ou `entrance_y_2.tscn` (passage vertical). Son nom encode toute l'information de routage :

```
level_[scène_destination]_[spawnpoint_départ]_[spawnpoint_arrivée]
```

Exemples dans `level_01.tscn` :
- `level_04_08_05` → va au level_04, depuis le spawnpoint 08, arrive au spawnpoint 05
- `level_02_10_15` → va au level_02, depuis le spawnpoint 10, arrive au spawnpoint 15

---

## 2. Déclenchement de la transition (`entrance_x_2.gd` / `entrance_y_2.gd`)

Quand le joueur entre dans l'Area2D :

1. Extraire du nom du nœud : `scene_next`, `spawnpoint_current`, `spawnpoint_next`
2. Chercher le Marker2D `spawnpoint_[scène_actuelle]_[spawnpoint_current]_begin` dans la scène courante
3. Calculer l'offset : `player.position - begin_marker.position` → stocké dans `player_spawnpoint_position_x/y`
4. Sauvegarder tous les objets + état joueur (position, santé, attaque, défense)
5. Changer de scène vers `level_[scene_next].tscn`

L'offset préserve la position relative du joueur par rapport au marqueur d'entrée, pour que la sortie soit naturelle de l'autre côté.

---

## 3. Placement du joueur à l'arrivée (`base_level.gd`)

```gdscript
if Player_data.spawnpoint_next == "":
    # Chargement depuis sauvegarde → position absolue directe
    player.position = Vector2(player_spawnpoint_position_x, player_spawnpoint_position_y)
else:
    # Transition → begin_marker de la nouvelle scène + offset
    node = "spawnpoint_[nouvelle_scène]_[spawnpoint_next]_begin"
    player.position = get_node(node).position + Vector2(offset_x, offset_y)
```

Le même champ `player_spawnpoint_position_x/y` sert à deux usages distincts selon que `spawnpoint_next` est vide ou non.

---

## 4. Spawnpoints par niveau

Chaque niveau déclare ses marqueurs sous la forme `spawnpoint_[level]_[id]_begin` et `spawnpoint_[level]_[id]_end` (les marqueurs `_end` sont présents dans les scènes mais non utilisés par le code actuel).

| Niveau   | Spawnpoints                                        |
|----------|----------------------------------------------------|
| level_01 | `start` (440, 136) · `08_begin` (584, 0) · `10_begin` (256, -704) |
| level_02 | `15_begin` · `20_begin`                            |
| level_03 | `11_begin` · `10_begin`                            |
| level_04 | `05_begin` · `16_begin`                            |

---

## 5. Carte des connexions entre niveaux

```
level_01 ──(08 → 05)──▶ level_04
level_01 ──(10 → 15)──▶ level_02

level_02 ──(15 → 10)──▶ level_01
level_02 ──(20 → 11)──▶ level_03

level_03 ──(10 → 16)──▶ level_04
level_03 ──(11 → 20)──▶ level_02

level_04 ──(05 → 08)──▶ level_01
level_04 ──(16 → 10)──▶ level_03
```

Chaque connexion est bidirectionnelle et symétrique : les numéros de spawnpoint se correspondent d'un niveau à l'autre (ex. 08 ↔ 05 entre level_01 et level_04).

---

## 6. Chargement initial (`liblevel.load_game`)

- **Fichier de sauvegarde trouvé** : charge la scène sauvegardée, place le joueur aux coordonnées absolues enregistrées, `spawnpoint_next` reste `""`.
- **Aucun fichier** : utilise `Player_data_default` (level_01, position 440, 136).

---

## Points notables

- `entrance_x_2.gd` et `entrance_y_2.gd` ont un code identique — la différence est uniquement la forme de l'Area2D dans la scène (orientation du couloir).
- Les marqueurs `_end` sont présents dans les `.tscn` mais non utilisés par le code.
- Le `spawnpoint_level_01_start` (level_01 uniquement) sert de point de départ absolu par défaut, référencé uniquement dans les valeurs initiales, pas dans le code de transition.
