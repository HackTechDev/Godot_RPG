# Improvements — Commando Zombi RPG v4

Pistes d'amélioration identifiées pour les prochaines versions.

---

## Gameplay

### Système de santé fonctionnel
- `player_health` existe dans `Player_data` mais n'est jamais modifiée
- Ajouter des zones de dégâts (pièges, sols radioactifs) qui réduisent la santé au contact
- Sauvegarder `player_health` dans `rpg.json` (actuellement absent)

### Robots ennemis
- Créer un type `RobotEnemy` (`CharacterBody2D`) distinct des robots collectables
- IA simple : détection du joueur dans un rayon, déplacement vers lui
- Inflige des dégâts au contact avec un cooldown pour éviter les dégâts répétés
- Chargeable depuis `level_01.json` avec le type `"robot_enemy"`

### Objets de soin
- Nouveau type d'objet collectable (`health_item`) qui restaure 1 point de santé
- Même système d'interaction que les ordinateurs et robots (T pour ramasser)
- Max santé : 4 (valeur de `player_health` par défaut)

### Écran Game Over
- Déclenchement quand `player_health <= 0`
- Panneau overlay avec message, bouton "Recommencer" et bouton "Quitter"
- "Recommencer" réinitialise `Player_data` et retourne au menu principal

### Objectifs / quêtes simples
- Définir des objectifs par niveau (ex. : "Collecter 3 ordinateurs")
- Afficher la progression dans le HUD
- Déclencher un événement (ouverture de porte, passage vers la zone suivante) à la complétion

---

## Interface utilisateur

### Page Contrôles dans Settings
- La page "Controls" dans Settings affiche uniquement un label vide
- La remplir avec le tableau complet des touches du jeu :
  - Déplacement : Flèches / ZQSD
  - Menu : M
  - Fiche personnage : P
  - Ramasser : T
  - Pousser : R
  - Construire : B

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

---

## Sauvegarde

### Sauvegarde de la santé
- Ajouter `"player_health"` dans `data_to_save()` (`main_menu.gd`)
- Lire et restaurer la valeur dans `load_game()` (`liblevel.gd`)
- Mettre à jour `World/Default/rpg.json` avec `"player_health": 4`

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

### Système de dialogue / PNJ
- Ajouter des personnages non-joueurs avec lesquels interagir (touche T)
- Boîte de dialogue simple avec texte et bouton "Suivant"

### Nettoyage du code
- `level_01.gd` n'étend pas `base_level.gd` contrairement aux autres niveaux — à unifier
- Le `print("evet")` dans `player.gd` est à supprimer
- La variable `paused` dans `player.gd` est déclarée mais jamais utilisée (remplacée par `display_menu`)
