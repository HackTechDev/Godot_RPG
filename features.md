# Features — Commando Zombi RPG v4

Récapitulatif de toutes les modifications apportées au projet.

---

## Fiche de personnage (touche P)

- Affiche un panneau centré avec : santé, ordinateurs collectés, robots collectés, zone actuelle, inventaire
- S'ouvre/ferme avec la touche **P**
- Se met à jour à chaque ouverture
- Bouton "Fermer" intégré
- **Fichiers :** `UI/character_sheet.tscn`, `UI/character_sheet.gd`

---

## Système de collision et poussée physique

- Les objets `Computer` et `Robot` sont passés de `Area2D` à `RigidBody2D`
- Le joueur pousse physiquement les objets en marchant dessus (`move_and_slide`)
- Propriétés : `gravity_scale = 0`, `linear_damp = 8`, `freeze_rotation = true`
- **Fichiers :** `Objects/Computers/computer.tscn`, `Objects/Robots/robot.tscn`

---

## Interaction avec les objets (touches T et R)

- **T** — ramasse l'objet au contact (incrémente le compteur + ajoute à l'inventaire)
- **R** — pousse l'objet dans la direction du regard du joueur (`apply_central_impulse`)
- Détection de proximité via une `Area2D` enfant (rayon 16) indépendante de la physique
- Label "T: Prendre / R: Pousser" affiché sur l'objet quand le joueur est à portée
- `Player_data.contact_object` stocke la référence à l'objet en contact
- Vérification `is_instance_valid()` avant tout appel sur `contact_object`
- **Fichiers :** `Objects/Computers/computer.gd`, `Objects/Robots/robot.gd`, `Scenes/Player/player.gd`, `project.godot`

---

## HUD en jeu

- Panneau permanent en haut à gauche affichant : santé, ordinateurs, robots, zone
- Mis à jour en temps réel via `_process`
- **Fichiers :** `UI/hud.tscn`, `UI/hud.gd`

---

## Notifications in-game

- Message temporaire apparaissant en haut de l'écran lors d'une collecte
- Exemples : "Ordinateur collecté !", "Robot collecté !"
- Affiché 1,5 s puis disparaît en fondu (0,5 s)
- Basé sur le signal `EventBus.item_collected`
- **Fichiers :** `UI/notification.tscn`, `UI/notification.gd`, `Autoload/EventBus.gd`

---

## Inventaire

- `Player_data.inventory` stocke la liste des objets collectés (Array de dictionnaires)
- Chaque entrée contient : `type` et `label`
- Affiché dans la fiche de personnage (touche P)
- **Fichiers :** `Scenes/Player/player_data.gd`, `UI/character_sheet.gd`

---

## Pause quand le menu est ouvert

- `get_tree().paused = true` à l'ouverture du menu M, `false` à la fermeture
- Le joueur est en `PROCESS_MODE_ALWAYS` pour rester réactif (touche M pour fermer)
- Le mouvement est bloqué pendant la pause
- **Fichiers :** `Scenes/Player/player.gd`

---

## Auto-save des positions d'objets

- Sauvegarde automatique des positions des objets à la fermeture du menu M
- Sauvegarde automatique lors des transitions de zone (entrances)
- Les déplacements après poussée (touche R) sont ainsi persistés
- **Fichiers :** `Scenes/Player/player.gd`, `Scenes/Levels/entrance_x_2.gd`, `Scenes/Levels/entrance_y_2.gd`

---

## Transitions de scènes (fondu noir)

- Fondu au noir avant chaque changement de scène, fondu depuis le noir à l'arrivée
- Implémenté comme autoload (`SceneTransition`) persistant entre les scènes
- `SceneTransition.change_scene(path)` remplace tous les `change_scene_to_file`
- `SceneTransition.fade_in()` appelé dans le `_ready()` de chaque scène
- **Fichiers :** `Autoload/scene_transition.gd`, `project.godot`

---

## Identification du joueur par groupe

- `add_to_group("player")` dans `player.gd._ready()`
- Tous les `body.name == "Player"` remplacés par `body.is_in_group("player")`
- Plus robuste en cas de renommage du nœud
- **Fichiers :** `Scenes/Player/player.gd`, `Objects/Computers/computer.gd`, `Objects/Robots/robot.gd`, `Scenes/Levels/entrance_x_2.gd`, `Scenes/Levels/entrance_y_2.gd`

---

## Page Audio dans les Settings

- Accessible depuis **Settings → Audio**
- Toggle pour activer/désactiver la musique (`stream_paused`)
- Slider de volume (0–100, conversion linéaire → dB)
- Paramètres sauvegardés dans `user://settings.json` et rechargés au démarrage
- **Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`

---

## Bouton Reinitialize

- Réinitialise les fichiers de sauvegarde depuis `res://World/Default/`
- Remet toutes les variables `Player_data` à zéro (évite les conflits au rechargement)
- `get_tree().paused = false` pour gérer l'appel depuis le menu in-game
- Retour au menu principal sans quitter le jeu
- **Fichiers :** `UI/main_menu.gd`

---

## Confirmation avant de quitter

- Clic sur "Quit" ouvre une `ConfirmationDialog` native Godot
- Boutons : "Quitter" (confirme et sauvegarde) / "Annuler"
- La sauvegarde n'est déclenchée qu'en cas de confirmation
- **Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`
