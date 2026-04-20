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

### Écran de chargement stylisé
- Afficher un vrai écran "Chargement..." avec barre de progression
- Nécessite `ResourceLoader` en mode thread pour un chargement asynchrone

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

### Affichage du cône de vision conditionnel
- Le cône de vision et la flèche de corps sont toujours affichés, même sans activation des contrôles pavé numérique
- Envisager une option pour masquer ces indicateurs (toggle dans Settings ou touche dédiée)

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

### Logs de debug désactivables
- Les `print()` dans le code (saveAllObjects, load game, etc.) conditionnés à une constante `DEBUG = false`
- Améliore les performances et la lisibilité des logs à l'export

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
