# Improvements — Commando Zombi RPG v4

Pistes d'amélioration identifiées pour les prochaines versions.

---

## Gameplay

### Système de santé fonctionnel
- Ajouter des zones de dégâts (pièges, sols radioactifs) qui réduisent la santé au contact
- La santé est réduite par les `RobotEnemy` mais le HUD ne change pas de couleur / aucune réaction visuelle côté joueur

### Objets de soin
- Nouveau type d'objet collectable (`health_item`) qui restaure 1 point de santé
- Même système d'interaction que les ordinateurs et robots (T pour ramasser)
- Max santé : utiliser `player_health_base` comme plafond (valeur définie à la création du personnage)

### Effets de spécialisation sur le gameplay
- La spécialisation choisie à la création pourrait modifier les stats ou débloquer des capacités
- Exemples : Médecin de combat → récupère +1 PV après un combat gagné ; Tireur de précision → bonus d'attaque à distance

### Objectifs de mission intégrés au HUD
- Afficher les objectifs de la mission active en cours de partie (panneau rétractable ou coin d'écran)
- Alimenté par `missions.json`, persisté dans `Player_data` ou un autoload dédié
- Objectifs cochables : déclencher un événement (ouverture de porte, transition) à la complétion

### Progression et état des missions
- Mémoriser quelle mission est en cours (`user://current_mission.json`)
- Marquer les missions comme terminées, afficher un récapitulatif en fin de mission
- Débloquer les missions suivantes selon la progression

### Portes et clés
- Ajouter des objets `door` bloquant le passage entre zones
- Une clé (`key_item`) collectée via T déverrouille la porte correspondante
- État ouvert/fermé persisté dans le JSON du niveau

### Expérience et niveaux du joueur
- Gagner des XP en tuant des robots ennemis
- Seuils de niveau : augmentent `player_attack` ou `player_defense` automatiquement
- Affiché dans la fiche de personnage (touche P)

### Dialogues persistants
- Mémoriser les choix déjà faits pour chaque PNJ (`user://npc_state.json`)
- Permettre à un PNJ de donner un objet ou d'ouvrir une porte selon les réponses du joueur

---

## Interface utilisateur

### Minimap
- Petite carte en coin d'écran montrant la position du joueur dans le niveau
- Peut être générée dynamiquement depuis les données de la TileMap

### Tutoriel / première fois
- Détecter si c'est la première partie (`user://rpg.json` absent)
- Afficher des bulles d'aide contextuelles (ex. : "Appuyez sur T pour ramasser")
- Disparaissent après la première utilisation de chaque action

### Fiche de personnage enrichie
- Afficher le grade, la spécialisation et la biographie dans la fiche (touche P)
- La biographie pourrait apparaître dans un onglet ou un panneau dédié

### Indicateur de santé visuel
- Le HUD change de couleur (vert → orange → rouge) selon les PV restants
- Flash rouge sur les bords de l'écran quand le joueur prend un coup

### Journal de quête
- Panneau accessible depuis le HUD listant les objectifs actifs et complétés
- Alimenté par un fichier JSON de quête par niveau

---

## Sauvegarde

### Plusieurs slots de sauvegarde
- 3 profils indépendants : `rpg_slot1.json`, `rpg_slot2.json`, `rpg_slot3.json`
- Idem pour les niveaux : `level_01_slot1.json`, etc.
- Interface de sélection de slot avant le bouton "Play"
- Affichage du dernier enregistrement par slot

---

## Technique

### Sons d'effets
- Son de collecte quand T est pressé sur un objet
- Son de poussée quand R est pressé
- Son de dégâts si un ennemi touche le joueur

### Animations des objets
- Animation d'apparition pour les objets spawnés (scale de 0 à 1)
- Animation de disparition avant `queue_free()` lors de la collecte

### Musique par niveau
- Chaque niveau joue une piste musicale différente
- Transition en fondu entre les pistes au changement de zone
- Le volume respecte le slider de la page Audio

### Pool d'objets pour les ennemis
- Au lieu de `queue_free()` + `instantiate()`, recycler les instances de `RobotEnemy`
- Améliore les performances sur les niveaux avec beaucoup d'ennemis

---

## Combat

### Fuite avec dés
- La fuite (touche C en combat) utilise encore un tirage interne sans overlay CombatUI
- À améliorer pour afficher le dé de fuite dans l'overlay et attendre Espace

### Équilibrage du combat
- Avec le wizard de création, le joueur peut allouer 0–30 points en attaque/défense — la plage effective est donc beaucoup plus large qu'avant (anciennement 10–15 fixe)
- Envisager des valeurs minimales par stat (ex. : min 5) pour éviter un personnage déséquilibré (tout en santé, 0 en attaque)
- Calibrer la difficulté des ennemis en fonction des nouvelles plages possibles

---

## Apparence du personnage

### Éditeur d'apparence en cours de partie
- Permettre de modifier l'apparence depuis la fiche de personnage (touche P) ou le menu in-game
- Les changements sont sauvegardés dans `rpg.json` et appliqués immédiatement via `_apply_appearance()`

### Sprites LPC supplémentaires
- Enrichir les options de chaque slot au fil des imports (nouvelles couleurs de peau, coiffures, armures…)
- Ajouter un ZIP LPC dans `res://Sprites/Player/` suffit — `SpriteLibrary` le découvre automatiquement au démarrage

### Sprite LPC pour les PNJ et ennemis
- Utiliser le même système de layers LPC pour habiller les PNJ et les `RobotEnemy`
- Permet une variété visuelle sans créer de nouvelles textures manuellement

---

## Cône de vision

### Impact du cycle jour/nuit sur la détection
- La nuit : portée de détection des ennemis réduite (visibilité diminuée pour tout le monde)
- Complète logiquement le cycle jour/nuit déjà en place

---

## Cycle jour/nuit

### Couleur de l'overlay selon l'heure
- Coucher de soleil : teinte orangée avant de passer au bleu nuit
- Aube : teinte violacée / rosée avant le retour au blanc
- Implémenter via `lerp` sur la couleur de `NightOverlay` en plus de l'alpha

### Impact gameplay de la nuit
- Ennemis plus nombreux ou plus rapides entre 22h00 et 05h00
- Zones sûres uniquement accessibles le jour (portes verrouillées la nuit)

### Indicateur visuel de l'heure sur le HUD
- Petite icône soleil/lune à côté de l'horloge qui change selon la phase du jour
- Barre de progression circulaire représentant l'avancement de la journée

---

## Menu radial

### Support manette / gamepad
- Maintenir un bouton de la manette pour ouvrir le menu radial
- Navigation au stick analogique gauche pour sélectionner l'action mise en surbrillance
- Relâcher le bouton confirme l'action sélectionnée

---

## Mecha

### Armement du Mecha
- Ajouter une arme intégrée au Mecha (mitrailleuse, lance-roquettes) déclenchée par une touche dédiée
- Dégâts et portée supérieurs au combat à pied ; munitions limitées par mission

### Santé et destruction du Mecha
- Le Mecha accumule des dégâts reçus (ennemis, mines, pièges)
- Quand la santé du Mecha tombe à 0, le joueur est éjecté et le Mecha est détruit (inutilisable jusqu'à réinitialisation)
- Afficher la santé du Mecha dans le HUD pendant le pilotage

### Mecha multi-joueur / mission
- Certaines missions pourraient nécessiter le Mecha pour franchir des zones (obstacles, distances)
- Un Mecha cassé bloque l'accès à ces zones → encourage à l'utiliser avec précaution

### Variantes de Mecha
- Plusieurs types de Mechas (léger / lourd) avec vitesse, hitbox et armement différents
- Type défini par `mecha_type` dans `mechas.json`

### Son du Mecha
- Son moteur en boucle pendant le déplacement (différent des pas du joueur)
- Son d'impact quand le Mecha heurte un mur

### Sprite directionnel (fait)
- `AnimatedSprite2D` avec sprite sheet 3×4 (`mecha_spider_sheet.png`) — 4 directions × 3 frames, 8 fps
- `_anim_for_dir(facing_dir)` → `walk_right / walk_left / walk_up / walk_down`
