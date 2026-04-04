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

---

## Nettoyage de code

- `level_01.gd` unifié avec les autres niveaux : étend désormais `base_level.gd` via `super._ready()`
- Le nœud `Player` supprimé de `level_01.tscn` (instancié dynamiquement par `base_level`)
- `build_computer_event` récupère le joueur via `get_tree().get_first_node_in_group("player")`
- `print("evet")` supprimé de `player.gd`
- Variable `paused` inutilisée supprimée de `player.gd`
- **Fichiers :** `Scenes/Levels/level_01.gd`, `Scenes/Levels/level_01.tscn`, `Scenes/Player/player.gd`

---

## Page Contrôles dans Settings

- Accessible depuis **Settings → Controls**
- Tableau complet des touches affiché dans un `GridContainer` (2 colonnes)
- Touches listées : Déplacement (Flèches/ZQSD), Menu (M), Fiche personnage (P), Ramasser (T), Pousser (R), Construire (B)
- Bouton "Retour" pour revenir aux Settings
- **Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`

---

## Sauvegarde de la santé

- `player_health` inclus dans `data_to_save()` et sauvegardé dans `user://rpg.json`
- Restauré au chargement via `load_game()` avec fallback sur la valeur par défaut
- `World/Default/rpg.json` mis à jour avec `"player_health": 4`
- **Fichiers :** `UI/main_menu.gd`, `Lib/liblevel.gd`, `World/Default/rpg.json`

---

## Robots ennemis

- Nouveau type `RobotEnemy` (`CharacterBody2D`) distinct des robots collectables
- Graphismes du joueur (`player_without_sword.png`) avec teinte rouge (`modulate`)
- AnimationTree identique au joueur : animations directionnelles idle/move 4 directions
- IA : détection du joueur dans un rayon de 120 px, déplacement à 35 px/s vers lui
- Inflige 1 point de dégât au contact (rayon 30 px) avec cooldown de 1,5 s
- Chargeable depuis les JSON de niveau avec le type `"robot_enemy"`
- Positions sauvegardées dans `user://levelXX.json` à chaque auto-save et changement de zone
- 3 robot ennemis par niveau dans les fichiers JSON par défaut
- **Fichiers :** `Objects/RobotEnemy/robot_enemy.gd`, `Objects/RobotEnemy/robot_enemy.tscn`, `Scenes/Levels/level_0[1-4].gd`, `Lib/liblevel.gd`, `Scenes/Player/player.gd`, `UI/main_menu.gd`, `World/Default/level_0[1-4].json`

---

## Splash screen

- Écran d'introduction avant le menu principal
- Affiche le titre **"Commando Zombi"** (fondu, 1,2 s) puis le sous-titre **"Mercenary RPG"** (fondu, 1,0 s)
- Transition automatique vers le menu principal après 3 s
- Peut être passé avec `Entrée` ou `Echap`
- **Fichiers :** `UI/splash_screen.tscn`, `UI/splash_screen.gd`, `project.godot`

---

## Système de combat au tour par tour (touches C et A)

- **C** — engage/quitte le combat avec le robot ennemi à portée (rayon 70 px)
- **A** — attaque pendant le combat (mouvement bloqué)
- Joueur : statistiques `player_attack` et `player_defense` (10–20, générées aléatoirement à la réinitialisation)
- Robot ennemi : statistiques `enemy_attack`, `enemy_defense` (10–20), `enemy_health` (2–3) générées aléatoirement à l'instanciation
- Résolution : tirage attaque/défense en [10,20] comparé à la stat correspondante
- Labels flottants au-dessus de chaque combattant (vert pour le joueur, rouge pour l'ennemi)
- Labels positionnés dynamiquement selon la direction relative joueur ↔ ennemi
- Auto-damage passif du robot suspendu pendant le combat
- **Fichiers :** `Scenes/Player/player.gd`, `Scenes/Player/player_data.gd`, `Objects/RobotEnemy/robot_enemy.gd`, `project.godot`

---

## Sauvegarde des stats de combat

- `player_attack` et `player_defense` inclus dans `data_to_save()` et `savePlayer()`
- Sauvegardés à la fermeture du jeu, à l'ouverture du menu M, et au changement de zone
- Restaurés au chargement via `load_game()` avec génération aléatoire si absent
- **Fichiers :** `UI/main_menu.gd`, `Lib/liblevel.gd`, `Scenes/Levels/entrance_x_2.gd`, `Scenes/Levels/entrance_y_2.gd`

---

## Stats de combat dans la fiche de personnage

- Attaque et Défense affichées dans la fiche (touche P) après la Santé
- Mis à jour à chaque ouverture via `refresh()`
- **Fichiers :** `UI/character_sheet.tscn`, `UI/character_sheet.gd`

---

## Objets et sauvegarde pour les niveaux 02–04

- 2 ordinateurs, 2 robots et 3 robot ennemis par niveau (02, 03, 04)
- Fichiers JSON par défaut créés dans `World/Default/`
- Scripts de niveau réécrits : chargement depuis `user://levelXX.json` (fallback sur le défaut)
- `reinitializeLevel()` copie désormais les 4 fichiers de niveau
- Sauvegarde au changement de zone inclut les `robot_enemy`
- **Fichiers :** `Scenes/Levels/level_02.gd`, `Scenes/Levels/level_03.gd`, `Scenes/Levels/level_04.gd`, `World/Default/level_02.json`, `World/Default/level_03.json`, `World/Default/level_04.json`, `Lib/liblevel.gd`, `Scenes/Levels/entrance_x_2.gd`, `Scenes/Levels/entrance_y_2.gd`
