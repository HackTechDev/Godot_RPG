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
- Max santé : 4 (valeur de `player_health` par défaut)

### Écran Game Over
- ~~Implémenté~~ — voir `features.md`

### Objectifs / quêtes simples
- Définir des objectifs par niveau (ex. : "Collecter 3 ordinateurs")
- Afficher la progression dans le HUD
- Déclencher un événement (ouverture de porte, passage vers la zone suivante) à la complétion

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

### Système de dialogue / PNJ
- Ajouter des personnages non-joueurs avec lesquels interagir (touche T)
- Boîte de dialogue simple avec texte et bouton "Suivant"

---

## Combat

### Retour visuel sur les dégâts
- Flash rouge sur le sprite du joueur ou du robot lors d'un coup reçu
- Petite animation de recul (`tween` sur la position)

### Délai entre les rounds
- Ajouter un court délai (0,5–1 s) entre l'affichage du résultat et le prochain tour
- Permet au joueur de lire le résultat avant que les labels ne changent

### Fuite du combat
- Permettre au joueur de quitter le combat avec un tirage de chance (ex. : touche C pendant le combat)
- Chance de fuite basée sur la différence de vitesse joueur/robot

### Touches de combat dans la page Contrôles
- Ajouter **C** (Combat) et **A** (Attaque) au tableau des contrôles dans Settings → Controls

### Persistance des stats de robot ennemi
- Actuellement les stats ATK/DEF/HP du robot ennemi sont regénérées à chaque chargement de scène
- Sauvegarder ces valeurs dans le JSON de niveau pour une cohérence entre sessions
