# Ajout de sprites LPC

## Architecture

Les sprites de personnage sont des **sprite sheets LPC** (Libre Pixel Character) composées en couches. Le système repose sur trois fichiers dans `Sprites/Player/` :

| Fichier | Rôle |
|---------|------|
| `character.json` | Catalogue des couches — exporté par le générateur LPC |
| `sprite_index.json` | Liste des noms de fichiers PNG présents dans `items/` |
| `items/*.png` | Sprite sheets individuelles — importées par Godot |

`SpriteLibrary` (autoload) lit ces trois fichiers au démarrage et construit un catalogue d'items par slot. La création de personnage (`main_menu.gd`) interroge `SpriteLibrary.get_slot_options(slot)` pour peupler les menus déroulants.

---

## Slots supportés par le jeu

| Clé de sélection LPC | Slot dans le jeu | Couche Sprite2D | Optionnel |
|----------------------|-----------------|-----------------|-----------|
| `body`       | `body`     | Body      | Non — obligatoire |
| `armour`     | `torso`    | Torso     | Oui |
| `legs`       | `legs`     | Legs      | Oui |
| `shoes`      | `feet`     | Feet      | Oui |
| `hair`       | `hair`     | Hair      | Oui |
| `hat`        | `headwear` | Headwear  | Oui |
| `arms`       | `arms`     | Arms      | Oui |
| `bracers`    | `arms`     | Bracers   | Oui (slot partagé avec arms) |
| `gloves`     | `hands`    | Hands     | Oui |
| `head`       | *(fixe)*   | _head     | — (tête, non sélectionnable) |
| `expression` | *(fixe)*   | _face     | — (visage, non sélectionnable) |
| `shoulders`  | *(ignoré)* | —         | — (non géré par le moteur) |

Les slots **optionnels** proposent automatiquement l'option « — » (aucun équipement).

---

## Convention de nommage des PNG dans `items/`

Chaque fichier est nommé :

```
NNN qualifier.png
```

- **NNN** = `zPos` de la couche dans `character.json`, formaté sur 3 chiffres (ex. `010`, `060`, `130`).
- **qualifier** = variant ou première valeur de recolor du layer LPC (ex. `light`, `steel`, `forest`).
- Les espaces et underscores multiples sont normalisés par `SpriteLibrary` pour générer la clé interne.

Exemples :

```
010 body_color__light_.png    → zPos=10,  qualifier="light"
025 basic_boots__black_.png   → zPos=25,  qualifier="black"
060 leather__forest_.png      → zPos=60,  qualifier="forest"
130 armet__iron_.png          → zPos=130, qualifier="iron"
```

Quand plusieurs fichiers partagent le même préfixe `NNN` (même zPos), le qualifier permet de les distinguer. Si un seul fichier a ce préfixe, le qualifier est ignoré.

---

## Ajouter une nouvelle variation de sprite

### Cas 1 — Nouvel équipement (nouvelle couleur/variante d'un slot existant)

**Exemple :** ajouter une armure de torse en coloris "blue".

**Étape 1 — Générer dans le LPC generator**

1. Aller sur le générateur LPC.
2. Sélectionner le slot souhaité (ex. `armour`) avec la variante "blue".
3. Télécharger le ZIP du personnage.

**Étape 2 — Extraire les fichiers**

Dans le ZIP exporté, récupérer le PNG du nouvel item depuis `items/`. Son nom suit la convention `NNN qualifier.png` (ex. `060 armour__blue_.png`).

Copier ce PNG dans :
```
Sprites/Player/items/060 armour__blue_.png
```

**Étape 3 — Ouvrir le projet dans Godot**

Godot détecte automatiquement le nouveau PNG et crée `060 armour__blue_.png.import`. L'import est nécessaire pour que le fichier soit inclus dans les exports.

**Étape 4 — Mettre à jour `sprite_index.json`**

Ajouter le nom du fichier dans `Sprites/Player/sprite_index.json` :

```json
[
  "010 body_color__light_.png",
  "060 armour__iron_.png",
  "060 armour__steel_.png",
  "060 armour__blue_.png",
  ...
]
```

**Étape 5 — Mettre à jour `character.json`**

Ajouter une entrée dans le tableau `layers` et renseigner la `selections` correspondante. S'inspirer des entrées existantes :

```json
// Dans "selections" :
"armour": {
  "itemId": "torso_armour_blue",
  "name": "Armour (blue)"
}

// Dans "layers" :
{
  "itemId": "torso_armour_blue",
  "name": "Armour (blue)",
  "variant": "blue",
  "recolors": null,
  "zPos": 60,
  "layerNum": 1,
  "yPos": 0,
  "isCustom": false,
  "needsRecolor": false,
  "fileName": "torso/armour/plate/male/spellcast/blue.png"
}
```

> La clé de `selections` doit correspondre à l'une des clés LPC reconnues par le jeu (voir tableau ci-dessus). Le champ `fileName` est indicatif (chemin LPC interne) — le jeu ne l'utilise pas.

**Résultat :** au démarrage, `SpriteLibrary` charge le nouveau PNG et le slot `torso` de la création de personnage proposera "Armour (blue)".

---

### Cas 2 — Nouveau type de corps / tête (couche fixe)

Les couches `head` et `expression` sont **fixes** — elles ne sont pas sélectionnables en jeu. Un seul PNG est chargé pour chacune. Pour les remplacer :

1. Renommer le nouveau PNG selon la convention (`100 human_male__dark_.png` pour la tête).
2. Le placer dans `items/` et l'ajouter à `sprite_index.json`.
3. Dans `character.json`, remplacer l'entrée du layer `head` ou `face_neutral` par le nouveau `itemId`, et mettre à jour `selections` en conséquence.

---

### Cas 3 — Régénérer `sprite_index.json` automatiquement

Si plusieurs PNG ont été ajoutés ou renommés, régénérer l'index depuis la racine du projet :

```bash
bash Scripts/update_sprite_index.sh
```

---

## Pourquoi `sprite_index.json` est nécessaire

`DirAccess.open("res://...")` ne fonctionne pas dans les exports **web** de Godot 4 — le PCK est un filesystem virtuel plat, non itérable. `sprite_index.json` remplace le scan de répertoire : c'est un fichier texte importé normalement par Godot et inclus dans tous les exports.

---

## Résumé des fichiers à toucher

| Action | Fichiers à modifier |
|--------|-------------------|
| Ajouter une variante | `items/<nouveau>.png` + `sprite_index.json` + `character.json` |
| Régénérer l'index | `sprite_index.json` (script bash ci-dessus) |
| Remplacer tête/visage | `items/<nouveau>.png` + `sprite_index.json` + `character.json` (layers + selections) |
| Ajouter un slot ignoré (ex. shoulders) | Modifier `_SELECTION_TO_SLOT` dans `Autoload/sprite_library.gd` + ajouter un slot `appearance_*` dans `player_data.gd` et la création de personnage |
