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

### Splashscreen — indication visuelle
- Ajouter un texte "Press any key" sur le splashscreen pour indiquer au joueur qu'il doit appuyer sur une touche

---

## Sauvegarde

### Plusieurs slots de sauvegarde
- 3 profils indépendants : `rpg_slot1.json`, `rpg_slot2.json`, `rpg_slot3.json`
- Idem pour les niveaux : `level_01_slot1.json`, etc.
- Interface de sélection de slot avant le bouton "Play"
- Affichage du dernier enregistrement par slot

---

## Technique

### ~~Fuite mémoire à la fermeture~~ — Corrigé
- `liblevel.gd` passé à `extends RefCounted` — plus de nœuds orphelins

### Sons d'effets
- Son de collecte quand T est pressé sur un objet
- Son de poussée quand R est pressé
- Son de dégâts si un ennemi touche le joueur

### Animations des objets
- Animation d'apparition pour les objets spawnés (scale de 0 à 1)
- Animation de disparition avant `queue_free()` lors de la collecte

### ~~Système de dialogue / PNJ~~ — Implémenté
- PNJ avec sprite vert, nom flottant, touche Z, arbre de dialogue — voir `features.md`
- À étendre : animations du PNJ, conditions de dialogue selon l'état du joueur, dialogues persistants (mémoriser les choix)

---

## Combat

### ~~Retour visuel sur les dégâts~~ — Implémenté
### ~~Délai entre les rounds~~ — Implémenté
### ~~Fuite du combat~~ — Implémenté
### ~~Touches de combat dans la page Contrôles~~ — Implémenté
### ~~Persistance des stats de robot ennemi~~ — Implémenté
### ~~Écran de crédits au moment de quitter~~ — Implémenté
### ~~Système de dés avec animation et interaction Espace~~ — Implémenté
### ~~Game Over intégré dans le flux de combat~~ — Implémenté

### Fuite avec dés
- La fuite (touche C en combat) utilise encore un tirage interne sans overlay CombatUI
- À améliorer pour afficher le dé de fuite dans l'overlay et attendre Espace

### Équilibrage du combat
- La plage 10–15 pour attaque/défense avec dés 1–20 donne un taux de réussite de 45–70 %
- Envisager une plage dynamique selon le niveau ou l'expérience du joueur

