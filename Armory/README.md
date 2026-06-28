# Package Items + Images

Ce ZIP contient les 4 fichiers JSON de tes 40 items (armes, gadgets,
protections, vêtements) avec un champ `images` cohérent, plus un script
qui télécharge les images depuis les URLs que tu fournis dans
`image_url.txt`.

## Contenu

```
items_package/
├── weapons.json         # 12 items (armes)
├── gears.json           # 10 items (gadgets)
├── protections.json     # 8 items (protections)
├── clothes.json         # 10 items (vêtements)
├── image_url.txt        # liste des URLs (à compléter)
├── download_images.py   # script de téléchargement
├── images/              # destination des images
└── README.md
```

## Convention de nommage

Pour chaque item, 3 images numérotées :

```
images/{item_id}_1.jpg
images/{item_id}_2.jpg
images/{item_id}_3.jpg
```

Exemple pour le HK416 (`id = weapon_hk416_a5`) :
```
images/weapon_hk416_a5_1.jpg
images/weapon_hk416_a5_2.jpg
images/weapon_hk416_a5_3.jpg
```

Le champ `images` de chaque item dans les JSON pointe déjà vers ces chemins.

## Utilisation

### 1. Compléter `image_url.txt`

Le fichier contient déjà toutes les clés (120 lignes au total : 40 items × 3
images), commentées par défaut. Pour activer une ligne :

1. supprime le `#` en début de ligne
2. colle l'URL de l'image après le `=`

Exemple, avant :
```
# Fusil d'assaut HK416 (HK416 A5)
#weapon_hk416_a5_1=
#weapon_hk416_a5_2=
#weapon_hk416_a5_3=
```

Après :
```
# Fusil d'assaut HK416 (HK416 A5)
weapon_hk416_a5_1=https://upload.wikimedia.org/wikipedia/commons/.../HK416.jpg
weapon_hk416_a5_2=https://...autre-photo.jpg
weapon_hk416_a5_3=https://...troisieme-photo.jpg
```

Tu peux n'activer que certaines lignes — le script ignore les lignes
commentées et téléchargera uniquement ce qui est renseigné.

### 2. Installer les dépendances

```bash
pip install requests pillow
```

`pillow` est optionnel mais recommandé : il convertit les images en JPEG,
les redimensionne (max 1280px de côté) et compresse à 85% de qualité.

### 3. Lancer le téléchargement

```bash
python download_images.py
```

Le script affiche sa progression avec un compteur `[N/total]`. Il :
- saute les fichiers déjà présents dans `images/`
- affiche un bilan final (téléchargées / déjà présentes / échecs)

### 4. Reprendre après une coupure ou un échec

Le script est **idempotent**. Tu peux le relancer autant de fois que tu
veux : il ne retéléchargera pas ce qui est déjà dans `images/`.

Pour remplacer une image : supprime le fichier dans `images/`, change l'URL
correspondante dans `image_url.txt`, et relance.

## Format précis de `image_url.txt`

```
# commentaire (ligne ignorée)
weapon_hk416_a5_1=https://example.com/photo.jpg
weapon_hk416_a5_2=https://example.com/photo2.jpg
                              ↑ pas d'espace autour du = (mais tolérés)
```

Règles :
- Une paire `clé=url` par ligne
- Lignes vides ignorées
- Lignes commençant par `#` ignorées
- Si une clé apparaît plusieurs fois, la dernière l'emporte
- Une URL doit être directement téléchargeable (pas une page HTML)

## Configuration du script

En haut de `download_images.py`, tu peux ajuster :

| Variable           | Défaut | Effet                                       |
|--------------------|--------|---------------------------------------------|
| `MAX_DIMENSION`    | 1280   | Côté max (px), `None` pour désactiver       |
| `JPEG_QUALITY`     | 85     | Qualité JPEG (1-100)                        |
| `REQUEST_DELAY`    | 0.3    | Délai entre téléchargements (secondes)      |
| `REQUEST_TIMEOUT`  | 30     | Timeout par requête (secondes)              |

## Items couverts (40 au total)

**Armes** (12) : HK416, M4A1 SOPMOD, SCAR-H, MP5SD, P90, Glock 17, SIG P226,
MK23 SOCOM, M110 SASS, L96A1, Benelli M4, Couteau tactique.

**Gadgets** (10) : Drone DR-1, NVG PVS-31, Vision thermique TS-1, Flashbang
M84, Fumigène M18, Medkit, Crochetage, Charge de brèche, Brouilleur JM-2,
Radio TR-5.

**Protections** (8) : Plate Carrier MK2, Gilet léger, Armure lourde MK3,
Stealth Carrier, Bouclier balistique, Casque FAST, Casque lourd MK2,
Genouillères/coudières.

**Vêtements** (10) : Urban Stealth, Night Ops, Combat Suit MK2, Forest Camo,
Desert Camo, Arctic Ops, Worker Outfit, Field Medic, Black Ops MK1,
Light Exosuit.

## Sources d'images suggérées

Pour trouver des URLs d'images libres :
- **Wikimedia Commons** : https://commons.wikimedia.org (CC-BY-SA / domaine public)
- **DVIDS** : https://www.dvidshub.net (photos militaires US, domaine public)
- **Unsplash / Pexels** : https://unsplash.com / https://pexels.com (libre)

Sur Wikimedia Commons, pour obtenir l'URL directe d'une image : ouvre la page
du fichier, clic droit sur l'image → "Copier l'adresse de l'image".
