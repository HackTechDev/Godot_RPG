# Procédure : Créer un nouveau niveau avec transitions

## Vue d'ensemble

Un niveau est composé de :
- Un script `.gd` héritant de `base_level.gd`
- Une scène `.tscn` contenant la TileMap, les zones de transition et les spawnpoints
- Un fichier JSON de données par défaut dans `res://World/Default/`

Les transitions reposent entièrement sur le **nom des nœuds d'entrée**, qui encode la destination et les identifiants de spawnpoints.

---

## Étape 1 — Choisir les identifiants de spawnpoints

Chaque spawnpoint est identifié par un **numéro unique par niveau** (ex. `01`, `25`, `30`…).

Avant de créer le niveau, noter :
- L'identifiant du spawnpoint dans le **nouveau niveau** (ex. `01`)
- L'identifiant du spawnpoint dans le **niveau de destination** (ex. `25`)
- Le numéro du niveau destination (ex. `level_02`)

Vérifier que les numéros choisis ne sont pas déjà utilisés dans les niveaux concernés :

| Niveau   | Spawnpoints déjà utilisés |
|----------|---------------------------|
| level_01 | 08, 10                    |
| level_02 | 15, 20, 25                |
| level_03 | 11, 10                    |
| level_04 | 05, 16                    |
| level_05 | 01                        |

---

## Étape 2 — Créer le script du niveau

Créer `Scenes/Levels/level_XX.gd` :

```gdscript
extends "res://Scenes/Levels/base_level.gd"

@onready var robot_enemy_scene = preload("res://Objects/RobotEnemy/robot_enemy.tscn")

func _ready():
	super._ready()
	_load_objects()

func _load_objects():
	var datas = _read_level_json("user://level_XX.json", "res://World/Default/level_XX.json")
	for key in datas:
		var data
		if datas[key].object == "robot_enemy":
			data = robot_enemy_scene.instantiate()
			data.add_to_group("robot_enemy")
		else:
			continue
		data.position.x = datas[key].position.x
		data.position.y = datas[key].position.y
		add_child(data)
		if datas[key].has("attack"):
			data.enemy_attack = int(datas[key].attack)
			data.enemy_defense = int(datas[key].defense)
			data.enemy_health = int(datas[key].health)
			if datas[key].get("dead", false):
				data.death_rotation = float(datas[key].get("death_rotation", PI / 2.0))
				data.apply_dead_state()

func _read_level_json(save_path: String, default_path: String) -> Dictionary:
	for path in [save_path, default_path]:
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			var datas = JSON.parse_string(file.get_as_text())
			file.close()
			if datas != null:
				return datas
	return {}
```

Remplacer `XX` par le numéro du niveau.

---

## Étape 3 — Créer la scène `.tscn`

Dans l'éditeur Godot :

1. **Créer une nouvelle scène** de type `Node2D`, nommer le nœud racine `level_XX`
2. **Attacher le script** `Scenes/Levels/level_XX.gd`
3. **Ajouter un TileMap** (nœud enfant nommé `ground`)
   - Assigner le TileSet partagé (copier depuis un niveau existant ou utiliser le même asset `tileset_scifi.png`)
   - Dessiner la carte avec les tuiles de sol et de murs
4. **Ajouter les zones de transition** (voir Étape 4)
5. **Ajouter les spawnpoints** (voir Étape 5)
6. **Sauvegarder** sous `Scenes/Levels/level_XX.tscn`

---

## Étape 4 — Ajouter les zones de transition (entrées)

Pour chaque connexion avec un autre niveau, instancier la scène d'entrée appropriée :

| Scène                          | Forme de la zone | Usage                         |
|-------------------------------|------------------|-------------------------------|
| `entrance_x_2.tscn` (128×16) | Horizontale      | Passage haut / bas            |
| `entrance_y_2.tscn` (16×128) | Verticale        | Passage gauche / droite       |

### Nommage obligatoire

Le nom du nœud d'entrée doit suivre exactement ce format :

```
level_[destination]_[sp_courant]_[sp_destination]
```

**Exemple :** le joueur est dans `level_XX` au spawnpoint `01`, il va vers `level_02` au spawnpoint `25` :
```
level_02_01_25
```

### Placement

- Placer la zone sur le **bord de la carte**, à l'endroit du passage
- La zone doit être accessible par le joueur (ne pas être dans un mur)
- Positionnement indicatif :
  - Passage gauche/droite → `entrance_y_2`, aligner sur le mur latéral
  - Passage haut/bas → `entrance_x_2`, aligner sur le mur supérieur/inférieur

---

## Étape 5 — Ajouter les spawnpoints

Pour chaque zone de transition, ajouter **deux Marker2D** dans la scène :

```
spawnpoint_level_XX_[id]_begin    ← point d'entrée (utilisé pour positionner le joueur)
spawnpoint_level_XX_[id]_end      ← point de sortie (non utilisé dans le code actuel)
```

**Règle de placement :**
- `_begin` : placer **à l'intérieur de la carte**, à ~64–128 px du bord, dans l'axe du passage
- `_end` : placer à ~128 px de `_begin`, dans la même direction

**Exemple** pour un passage sur le bord gauche (entrée_y_2 à x=0, y=352) :
```
spawnpoint_level_XX_01_begin  →  position (80, 288)
spawnpoint_level_XX_01_end    →  position (80, 416)
```

---

## Étape 6 — Modifier le niveau de destination

Dans la scène du niveau voisin (`level_YY.tscn`) :

1. **Ajouter une zone de transition** en miroir :
   - Nom : `level_XX_[sp_destination]_[sp_courant]`
   - Exemple : `level_XX_25_01`
   - Même type d'entrance que côté level_XX

2. **Ajouter les spawnpoints miroir** :
   ```
   spawnpoint_level_YY_[sp_destination]_begin
   spawnpoint_level_YY_[sp_destination]_end
   ```

3. Placer la zone et les spawnpoints à un **endroit accessible** dans level_YY

---

## Étape 7 — Créer le fichier JSON par défaut

Créer `World/Default/level_XX.json` avec un contenu minimal :

```json
{}
```

Ou pré-peupler avec des objets :

```json
{
  "robot_enemy1": {
	"scene": "level_XX",
	"object": "robot_enemy",
	"position": { "x": 320, "y": 320 },
	"attack": 12,
	"defense": 11,
	"health": 2,
	"dead": false,
	"death_rotation": 0.0
  }
}
```

---

## Étape 8 — Enregistrer le niveau dans liblevel.gd

Dans `Lib/liblevel.gd`, fonction `reinitializeLevel()`, ajouter `"level_XX"` à la liste :

```gdscript
for level in ["level_01", "level_02", "level_03", "level_04", "level_05", "level_XX"]:
	dir.copy("res://World/Default/%s.json" % level, "user://%s.json" % level)
```

---

## Récapitulatif des connexions actuelles

```
level_01 ──(08 → 05)──▶ level_04
level_01 ──(10 → 15)──▶ level_02

level_02 ──(15 → 10)──▶ level_01
level_02 ──(20 → 11)──▶ level_03
level_02 ──(25 → 01)──▶ level_05

level_03 ──(10 → 16)──▶ level_04
level_03 ──(11 → 20)──▶ level_02

level_04 ──(05 → 08)──▶ level_01
level_04 ──(16 → 10)──▶ level_03

level_05 ──(01 → 25)──▶ level_02
```

---

## Checklist

- [ ] Script `level_XX.gd` créé
- [ ] Scène `level_XX.tscn` créée avec TileMap
- [ ] Nœuds d'entrée nommés correctement (`level_[dest]_[sp_courant]_[sp_dest]`)
- [ ] Spawnpoints `_begin` et `_end` ajoutés dans level_XX
- [ ] Entrée miroir ajoutée dans le niveau de destination
- [ ] Spawnpoints miroir ajoutés dans le niveau de destination
- [ ] `World/Default/level_XX.json` créé
- [ ] `level_XX` ajouté dans `reinitializeLevel()` de `liblevel.gd`
