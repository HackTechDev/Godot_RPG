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

- **C** — engage le combat (ennemi à rayon 70 px) ou tente une fuite (50 % de chance, basée sur la vitesse)
- **A** — attaque pendant le combat (mouvement bloqué, anti-spam avec délai de 0,8 s entre rounds)
- Joueur : statistiques `player_attack` et `player_defense` (10–20, aléatoires à la réinitialisation)
- Robot ennemi : `enemy_attack`, `enemy_defense` (10–20), `enemy_health` (2–3) aléatoires, persistés dans le JSON de niveau
- Résolution : tirage en [10,20] comparé à la stat → HIT/MISS/BLOCK
- **Fuite** : tirage [1–10] > 5 → échappement, sinon le robot contre-attaque
- **Flash + recul** : sprite du joueur flashe rouge, sprite du robot flashe blanc, les deux reculent de 6 px lors d'un coup reçu
- Labels flottants positionnés dynamiquement selon la direction relative joueur ↔ ennemi
- Auto-damage passif suspendu pendant le combat
- C et A ajoutés dans Settings → Controls
- **Fichiers :** `Scenes/Player/player.gd`, `Scenes/Player/player_data.gd`, `Objects/RobotEnemy/robot_enemy.gd`, `Lib/liblevel.gd`, `Scenes/Levels/level_0[1-4].gd`, `UI/main_menu.tscn`, `project.godot`

---

## Sauvegarde des stats de combat

- `player_attack` et `player_defense` inclus dans `data_to_save()` et `savePlayer()`
- Sauvegardés à la fermeture du jeu, à l'ouverture du menu M, et au changement de zone
- Restaurés au chargement via `load_game()` avec génération aléatoire si absent
- **Fichiers :** `UI/main_menu.gd`, `Lib/liblevel.gd`, `Scenes/Levels/entrance_x_2.gd`, `Scenes/Levels/entrance_y_2.gd`

---

## Écran Game Over

- Déclenché quand `Player_data.player_health <= 0` (détecté dans `_process` du joueur)
- Overlay semi-transparent noir + panneau centré avec titre rouge "GAME OVER"
- Bouton **Recommencer** : réinitialise toutes les variables `Player_data`, copie les fichiers par défaut, retourne au menu principal
- Bouton **Quitter** : ferme le jeu
- Le jeu est mis en pause (`get_tree().paused = true`) pendant l'affichage
- Le combat en cours est interrompu proprement avant l'affichage
- **Fichiers :** `UI/game_over.tscn`, `UI/game_over.gd`, `Scenes/Player/player.gd`

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

---

## Écran de crédits au moment de quitter

- Affiché automatiquement après confirmation de quitter (à la place du `quit()` direct)
- Fond noir, texte défilant vers le haut (style cinéma, 55 px/s)
- Sections : titre du jeu (doré), Développement, Musique, Moteur de jeu, remerciements, version
- Crédits : Le Sanglier des Ardennes — lesanglierdesardennes@gmail.com
- Appuyer sur n'importe quelle touche quitte immédiatement
- Le jeu ferme automatiquement quand tout le texte a défilé
- `get_tree().paused = false` forcé au démarrage pour fonctionner depuis le menu in-game (pause active)
- **Fichiers :** `UI/credits.tscn`, `UI/credits.gd`, `UI/main_menu.gd`

---

## Menu in-game amélioré (touche M et bouton Home)

- Le bouton "Play" est remplacé par **"Back to the game"** quand le menu est ouvert en cours de partie
- Cliquer "Back to the game" ferme le menu et reprend la partie (auto-save inclus), sans recharger la scène
- Le signal `.tscn` du bouton est déconnecté et rebranché sur `_close_menu()` dans `player.gd`
- Le bouton **Home** du HUD ouvre désormais le menu in-game (panneau principal) au lieu de retourner directement au menu principal
- **Fichiers :** `Scenes/Player/player.gd`

---

## Système de combat CQB avec dés (refonte complète)

- **C** près d'un ennemi → engage le combat ET lance immédiatement la séquence d'attaque
- **Échap** → quitte le combat immédiatement, annule toute attente en cours
- Overlay centré (`CombatUI`) affiché pendant tout le combat : message, animation de dé, résultat, prompt
- Dé animé : défilement de valeurs aléatoires (1–20) qui ralentit avant d'afficher le résultat final
- **Espace** requis pour lancer les dés du joueur (attaque et défense) ; les dés du robot sont automatiques
- Résultat réussi si valeur obtenue **strictement inférieure** à la statistique concernée (plage 1–20)
- Points d'attaque et défense : **10–15** (aléatoires) pour le joueur et les robots
- Chaque message de résultat reste affiché jusqu'à ce que le joueur appuie sur **Espace** pour continuer
- **Enchaînements automatiques :**
  - Attaque réussie du joueur → robot défend → si défense réussie → robot attaque
  - Attaque réussie du joueur → robot défend → si défense échouée et robot vivant → joueur attaque à nouveau
  - Robot attaque → si attaque réussie → joueur défend → si défense réussie → joueur contre-attaque
  - Robot attaque → si attaque réussie → joueur défend → si défense échouée → robot attaque à nouveau
  - Robot rate son attaque → joueur contre-attaque
- **Game Over in-combat** : si le joueur perd son dernier PV, l'overlay affiche "GAME OVER" + "[ ESPACE ] Recommencer" ; réinitialisation complète et retour au menu principal
- Label flottant du robot masqué à sa mort
- **Fichiers :** `UI/combat_ui.gd`, `UI/combat_ui.tscn`, `Scenes/Player/player.gd`, `Objects/RobotEnemy/robot_enemy.gd`

---

## Indicateurs visuels de spawnpoints (bleu)

- Chaque Marker2D nommé `spawnpoint_*` dans un niveau affiche automatiquement un carré bleu semi-transparent (32×32 px) à son emplacement
- Rendu en jeu via `_draw()` (remplissage + bordure bleue)
- Appliqué à tous les niveaux sans modification des `.tscn`, via `base_level.gd`
- **Fichiers :** `Scenes/Levels/base_level.gd`, `Scenes/Levels/spawnpoint_indicator.gd`

---

## Réorganisation des répertoires de niveaux

- Chaque niveau possède désormais son propre sous-répertoire : `Scenes/Levels/level_X/`
- Les fichiers `.gd` et `.tscn` de chaque niveau sont regroupés dans leur dossier respectif
- Les fichiers JSON par défaut sont également déplacés dans `World/Default/level_X/`
- Les fichiers de sauvegarde `user://` suivent la même structure : `user://level_X/level_X.json`
- Nommage sans zéro superflu : `level_1`, `level_2`, `level_3`, `level_4`
- Tous les chemins `res://` et `user://` mis à jour dans les scripts et scènes
- **Fichiers :** `Scenes/Levels/level_X/`, `World/Default/level_X/`, `Lib/liblevel.gd`, `Scenes/Levels/entrance_x_2.gd`, `Scenes/Levels/entrance_y_2.gd`

---

## Système de PNJ (NPC) avec dialogues

- Personnages non-joueurs identifiés par `npc_X` (ex. : `npc_1`, `npc_7`)
- Graphismes du joueur (`player_without_sword.png`) avec teinte verte (`modulate`)
- Nom du PNJ affiché en vert au-dessus du personnage
- Label "Z : Parler" visible à portée du joueur
- Touche **Z** déclenche l'ouverture de la boîte de dialogue
- Boîte de dialogue en bas d'écran : nom du PNJ, texte, choix multiples ou bouton "Suivant"
- Système d'arbre de dialogue : chaque nœud contient un texte et une liste de choix pointant vers le nœud suivant (`null` = fin)
- Configuration JSON par niveau : `Scenes/Levels/level_X/npc_X.json` (chargement automatique de tous les `npc_*.json` du répertoire)
- Mouvement du joueur bloqué pendant le dialogue (`get_tree().paused = true`)
- `Player_data.contact_npc` stocke la référence au PNJ en contact
- Premier PNJ : "Commandant Dubois" dans `level_1` avec 3 branches de dialogue
- **Fichiers :** `Objects/NPC/npc.gd`, `Objects/NPC/npc.tscn`, `UI/dialogue_box.gd`, `UI/dialogue_box.tscn`, `Scenes/Levels/level_1/npc_1.json`, `Scenes/Levels/level_1/level_1.gd`, `Scenes/Player/player.gd`, `Scenes/Player/player_data.gd`, `project.godot`

---

## Musique de fond sur le Splashscreen et les Crédits

- Le fichier `Sounds/music/les_commandos.mp3` joue automatiquement en fond sur le splashscreen et la page de crédits
- `AudioStreamPlayer` avec `autoplay = true` ajouté dans les deux scènes
- **Fichiers :** `UI/splash_screen.tscn`, `UI/credits.tscn`

---

## Image de fond sur le Splashscreen et les Crédits

- L'image `Images/special-forces-film.jpg` remplace le fond noir sur les deux pages
- Implémentée via un `TextureRect` (`expand_mode = 3`, `stretch_mode = 6`) en premier enfant du `CanvasLayer`
- Le `TextureRect` doit être enfant du `CanvasLayer` (pas du `Node2D` racine) pour que les ancres fonctionnent
- **Fichiers :** `UI/splash_screen.tscn`, `UI/credits.tscn`

---

## Splashscreen — transition sur pression d'une touche uniquement

- Le splashscreen ne passe plus au menu principal automatiquement après un délai
- La transition est déclenchée uniquement par `InputEventKey` (n'importe quelle touche)
- Le tween affiche le titre et le sous-titre en fondu, puis attend l'action du joueur
- **Fichiers :** `UI/splash_screen.gd`

---

## Traduction anglaise de l'interface

- Tous les textes français du menu principal traduits en anglais
- Concerné : page Audio (Music), page Controls (Movement, Arrows, Character sheet, Pick up, Push, Build, Combat / Flee, Attack, Talk to NPC), boutons Back, boîte de confirmation Quit
- **Fichiers :** `UI/main_menu.tscn`

---

## Documentation technique

- `cqb_system_combat.md` — règles complètes du système de combat (dés, enchaînements, contrôles)
- `level_transition_system.md` — analyse du système de transition et de spawn entre niveaux
- `procedure_creation_level.md` — procédure pas à pas pour créer un nouveau niveau avec transitions
- **Fichiers :** `cqb_system_combat.md`, `level_transition_system.md`, `procedure_creation_level.md`
