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

## Correction fuite mémoire à la fermeture

- `liblevel.gd` passé de `extends Node` à `extends RefCounted`
- Les instances créées avec `.new()` dans 5 scripts (`player.gd`, `main_menu.gd`, `game_over.gd`, `entrance_x_2.gd`, `entrance_y_2.gd`) étaient des nœuds orphelins non libérés à la fermeture
- Avec `RefCounted`, chaque instance est libérée automatiquement dès que son script parent est détruit
- Supprime les warnings `ObjectDB instances leaked at exit` et `resources still in use at exit` à l'export Linux
- **Fichiers :** `Lib/liblevel.gd`

---

## Création de personnage en wizard 4 pages

- Accessible depuis le menu principal via le bouton **"Create Character Sheet"**
- **Page 1 — Identité** : saisie du surnom (max 20 caractères) et d'une biographie libre (TextEdit multi-lignes)
- **Page 2 — Apparence** :
  - Zone de prévisualisation (fond blanc, 192×192 px, zoom ×3) rendue via `SubViewport` avec 12 `Sprite2D` empilées par `z_index`
  - Prévisualisation mise à jour en temps réel à chaque changement d'option
  - 8 slots configurables : Corps, Cheveux, Casque, Bras, Mains, Torse, Jambes, Pieds
  - Sprites LPC (Liberated Pixel Cup) 832×3456 px, 13×54 frames, format universel
  - Options disponibles : carnation claire, frange noire, armet fer, armure/brassards acier, gants noirs, cuir forêt, armure céramique, bottes noires
  - Personnage affiché de face (row 10, frame 130 = walk south)
- **Page 3 — Profil militaire** :
  - Menu déroulant Grade : Militaires du rang / Sous-officiers / Officiers / Officiers généraux
  - Liste de 8 spécialisations (ItemList) : Opérateur FS, Tireur de précision, Transmetteur, Démineur/EOD, Médecin de combat, Renseignement, Spéc. insertion, Spéc. appuis
  - Panneau description BBCode à droite, mis à jour en temps réel à la sélection
- **Page 4 — Statistiques** : répartition de 30 points entre Santé, Attaque et Défense via SpinBoxes ; compteur de points restants en temps réel
- À la validation ("Créer le personnage") : données sauvegardées dans `user://rpg.json`, niveaux réinitialisés depuis les défauts, jeu lancé directement sur `level_1`
- Données persistées dans `Player_data` et `rpg.json` : `player_nickname`, `player_biography`, `player_rank`, `player_specialization`, `player_health`, `player_health_base`, `player_attack`, `player_defense`, `appearance_body/hair/headwear/arms/hands/torso/legs/feet`
- Le surnom est affiché en temps réel dans le panneau HUD gauche ("Pseudo : …")
- **Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`, `Scenes/Player/player_data.gd`, `Lib/liblevel.gd`, `UI/hud.tscn`, `UI/hud.gd`

---

## Sprite LPC du personnage en jeu

- Le joueur affiche son sprite LPC composé de couches si une apparence a été configurée lors de la création ; sinon, le sprite par défaut (`player_without_sword.png`) est utilisé
- `AppearanceLayers` (Node2D) ajouté dans `player.tscn` avec 12 `Sprite2D` enfants (SpriteBody, SpriteLegs, SpriteFeet, SpriteShoulders, SpriteTorso, SpriteArms, SpriteBracers, SpriteGloves, SpriteHead, SpriteFace, SpriteHair, SpriteHeadwear)
- Compatibilité directe avec l'AnimationPlayer existant : les sheets LPC (13×54) partagent les mêmes numéros de frames 104–151 (rows 8–11 = walk 4 directions) que la sheet originale (13×21)
- `_apply_appearance()` appelé dans `_ready()` : charge les textures depuis `Player_data.appearance_*`, masque le sprite original
- `_process()` : synchronise le `frame` de chaque layer avec le `Sprite2D` master piloté par l'AnimationTree
- Flash de combat (`_flash_player_hit`) : applique le `modulate` rouge sur `AppearanceLayers` ou `Sprite2D` selon le mode actif
- Sprites stockés dans `Sprites/Player/items/` (12 fichiers PNG LPC)
- **Fichiers :** `Scenes/Player/player.tscn`, `Scenes/Player/player.gd`, `Sprites/Player/items/`

---

## Exclusivité des panneaux HUD (Sheet / Settings / Home)

- Les trois boutons du HUD (Sheet, Setting, Home) sont mutuellement exclusifs :
  - Clic **Sheet** : ferme le menu Settings s'il est ouvert, puis toggle la fiche de personnage
  - Clic **Setting** : ferme la fiche si elle est visible, puis ouvre/ferme le menu
  - Clic **Home** : ferme la fiche si elle est visible, puis ouvre le menu principal
- **Fichiers :** `Scenes/Player/player.gd`

---

## Documentation technique

- `cqb_system_combat.md` — règles complètes du système de combat (dés, enchaînements, contrôles)
- `level_transition_system.md` — analyse du système de transition et de spawn entre niveaux *(décrit l'ancien système entrance_x/y_2, remplacé)*
- `procedure_creation_level.md` — procédure pas à pas pour créer un nouveau niveau *(à mettre à jour : ancien système)*
- **Fichiers :** `cqb_system_combat.md`, `level_transition_system.md`, `procedure_creation_level.md`

---

## Chargement automatique des sprite sheets LPC (SpriteLibrary)

- Les sprite sheets ne sont plus codées en dur dans les scripts
- Au démarrage, `SpriteLibrary` scanne `res://Sprites/Player/*.zip` et charge chaque archive
- Pour chaque ZIP : lecture de `character.json` (format générateur LPC), correspondance automatique zPos → fichier PNG
- API exposée : `apply_sprite()`, `apply_preview_sprite_centered()`, `apply_head_sprite()`, `apply_face_sprite()`, `get_slot_options()`, `get_item_layer()`, `get_texture()`
- Ajouter un nouveau sprite = déposer un ZIP LPC dans `res://Sprites/Player/`, aucune modification de code
- **Fichiers :** `Autoload/sprite_library.gd`, `project.godot`

---

## Système de transitions de niveaux par fichier JSON

- Remplace entièrement l'ancien système `entrance_x_2` / `entrance_y_2`
- Les connexions entre niveaux sont définies dans `Scenes/Levels/<level>/level_connections.json`
- Format : connexions avec `trigger` (zone rectangulaire x/y/w/h) et `to.scene` (scène cible) — pas de spawn codé en dur
- Chaque niveau gère uniquement ses propres sorties ; la scène destination gère ses entrées dans son propre fichier
- Chargement automatique au démarrage du niveau depuis `base_level.gd`
- Zone trigger visualisée en orange semi-transparent (`Polygon2D`, `z_index = 10`) dans la scène en jeu
- **Fichiers :** `Scenes/Levels/base_level.gd`, `Scenes/Levels/level_X/level_connections.json`

---

## Transition déclenchée par la touche Espace avec spawn relatif

- La transition entre niveaux ne se déclenche plus automatiquement à l'entrée dans la zone
- Le joueur doit appuyer sur **Espace** avec son centre dans la zone trigger
- Cooldown de 0,5 s après l'arrivée dans un nouveau niveau pour éviter le re-déclenchement immédiat
- **Spawn relatif** : l'offset du joueur par rapport au centre du trigger source est appliqué au centre du trigger retour dans le niveau destination — la position relative est préservée
- `_compute_arrival_spawn()` lit le `level_connections.json` du niveau destination, trouve le trigger qui pointe vers le niveau courant et calcule la position d'arrivée
- **Fichiers :** `Scenes/Levels/base_level.gd`, `project.godot`

---

## Restauration du sprite après une transition

- La direction d'animation et le frame du sprite sont mémorisés avant chaque transition (`Player_data.player_sprite_frame`, `Player_data.player_facing`)
- À l'arrivée dans le nouveau niveau, `_restore_sprite_state()` restitue les `blend_position` de l'AnimationTree et le frame exact du sprite
- Évite le flash du frame par défaut (idle bas) à l'arrivée
- **Fichiers :** `Scenes/Player/player.gd`, `Scenes/Player/player_data.gd`, `Scenes/Levels/base_level.gd`

---

## Configuration des objets, ennemis et NPC par fichier JSON de niveau

- Chaque niveau possède ses propres fichiers de configuration dans `Scenes/Levels/<level>/` :
  - `objects.json` — computers et robots collectibles (type, x, y)
  - `enemies.json` — robots ennemis (x, y, attack, defense, health)
  - `npcs.json` — tous les PNJ du niveau (id, name, x, y, dialogue)
- Chargement centralisé dans `base_level.gd` via `_load_objects()`, `_load_enemies()`, `_load_npcs()`
- Priorité de chargement : `user://<level>/objects.json` (sauvegarde runtime) → fichier de config du niveau
- Les NPCs rechargent toujours depuis `npcs.json` (pas de sauvegarde runtime)
- `liblevel.saveAllObjects()` écrit désormais `user://<level>/objects.json` et `user://<level>/enemies.json` séparément
- `reinitializeLevel()` supprime les sauvegardes `user://` ; le jeu retombe automatiquement sur les configs
- `level_X.gd` réduits à `super._ready()` (level_1 conserve `build_computer_event`)
- **Fichiers :** `Scenes/Levels/base_level.gd`, `Scenes/Levels/level_X/*.json`, `Lib/liblevel.gd`

---

## Suppression du système de transition entrance_x_2 / entrance_y_2

- `entrance_x_2.gd/tscn` et `entrance_y_2.gd/tscn` supprimés
- `spawnpoint_indicator.gd` supprimé
- Tous les nœuds `entrance_*` et `spawnpoint_level_*` retirés des quatre `.tscn` de niveau
- `Player_data.spawnpoint_current` et `spawnpoint_next` supprimés
- `_place_player()` simplifié : spawn JSON → position sauvegardée
- **Fichiers :** `Scenes/Levels/base_level.gd`, `Scenes/Player/player_data.gd`, `Scenes/Player/player.gd`, `UI/main_menu.gd`, `UI/game_over.gd`, tous les `level_X.tscn`

---

## Position du joueur dans le HUD

- Le panneau en haut à gauche affiche en temps réel la position `x, y` du joueur
- Mis à jour à chaque frame dans `_process()`
- **Fichiers :** `UI/hud.tscn`, `UI/hud.gd`

---

## Réinitialisation → création de personnage directe

- Après **Reinitialize** (menu in-game) ou **Restart** (écran Game Over), le joueur est redirigé directement vers la page de création de personnage
- `Player_data.goto_character_creation` : flag transmis entre scènes via autoload
- `main_menu._ready()` détecte le flag et ouvre `CharacterCreation` automatiquement
- **Fichiers :** `UI/main_menu.gd`, `UI/game_over.gd`, `Scenes/Player/player_data.gd`

---

## Clic souris pour passer le splashscreen et les crédits

- En plus de n'importe quelle touche clavier, un clic souris suffit pour passer le splashscreen et quitter les crédits
- **Fichiers :** `UI/splash_screen.gd`, `UI/credits.gd`

---

## Détection de transition par confinement sur l'axe parallèle

- Pour un trigger **horizontal** (sortie haut/bas) : les bords gauche et droit de `sw_detect` doivent être contenus dans la plage X du trigger avant que la transition puisse se déclencher
- Pour un trigger **vertical** (sortie gauche/droite) : les bords haut et bas de `sw_detect` doivent être contenus dans la plage Y du trigger
- Évite les déclenchements accidentels quand le joueur effleure un coin de zone de sortie
- Appliqué dans `_process` (hint visuel) et `_unhandled_input` (déclenchement effectif)
- **Fichiers :** `Scenes/Levels/base_level.gd`

---

## Contrôle des effets sonores dans les paramètres Audio

- Nouvelle section dans **Settings → Audio** :
  - `CheckSfx` — activer / désactiver les effets sonores (activé par défaut)
  - `SliderSfxVolume` — volume des effets (0–100)
- `sfx_enabled` et `sfx_volume_linear` stockés dans `GameConfig` (autoload) et persistés dans `user://settings.json`
- `player.gd` applique le volume SFX au footstep à chaque appel de `movement_sounds()` ; coupe le son si les effets sont désactivés
- **Fichiers :** `Autoload/game_config.gd`, `UI/main_menu.tscn`, `UI/main_menu.gd`, `Scenes/Player/player.gd`

---

## Page de sélection de mission

- Affiché après le bouton **Play** (à la place de l'entrée directe en jeu)
- Les missions sont définies dans `missions.json` à la racine du projet :
  - `id`, `title`, `scene`, `spawn {x,y}`, `start_datetime`, `description`, `objectives`
- Interface : `ItemList` des missions + titre, date/heure de début, description, objectifs
- Bouton **Accepter** (désactivé tant qu'aucune mission n'est sélectionnée) : charge la sauvegarde, applique le spawn et l'horloge de mission, démarre la scène
- Bouton **Retour** : revient au menu principal
- Ajouter une mission = ajouter un objet dans `missions.json`, aucune modification de code
- 10 missions disponibles réparties sur les niveaux 1 à 4
- **Fichiers :** `missions.json`, `UI/main_menu.tscn`, `UI/main_menu.gd`

---

## Spawn du joueur initialisé depuis missions.json

- Le champ `spawn {x, y}` de chaque mission définit la position de départ du joueur
- Transmis via `Player_data.json_spawn` / `use_json_spawn`, appliqué par `base_level._place_player()`
- **Fichiers :** `missions.json`, `UI/main_menu.gd`, `Scenes/Player/player_data.gd`

---

## Horloge de mission en jeu

- Date et heure affichées en haut au centre de l'écran (format `JJ/MM/AAAA HHhMM`)
- 1 minute réelle = 1 heure de jeu
- Date/heure de début définie par `start_datetime` dans `missions.json`
- Calcul via timestamps Unix (`Time` API) : gestion automatique des rollovers
- **Fichiers :** `UI/hud.tscn`, `UI/hud.gd`, `Scenes/Player/player_data.gd`

---

## Cône de vision et rotation indépendante du corps

- **Cône vert** (FOV 90°, longueur 130 px) affiché depuis le centre du sprite : indique le champ de vision
- **Flèche orange** : indique la direction du corps
- Rotation du regard : **pavé num. 7 / 9**, pas de 45° — limité à ±90° du corps (simulation des limites naturelles de la tête)
- Rotation du corps : **pavé num. 4 / 6**, pas de 45°
- Le mouvement (flèches / WASD) est totalement dissocié du pavé numérique
- **Fichiers :** `Scenes/Player/player.gd`

---

## Règles de vitesse liées à l'orientation

- **Vitesse normale** (`player_speed_normal`, défaut 70 px/s) : corps = regard ET déplacement vers l'avant (dot > 1e-6)
- **Vitesse réduite** (`player_speed_slow`, défaut 35 px/s) dans tous les autres cas : regard ≠ corps, déplacement latéral (dot ≈ 0) ou recul (dot < 0)
- Paramètres configurables dans `GameConfig` (`Autoload/game_config.gd`)
- **Fichiers :** `Scenes/Player/player.gd`, `Autoload/game_config.gd`

---

## Monitors de debug dans le Debugger Godot

- Trois moniteurs personnalisés visibles dans **Debugger → Monitors → Joueur** :
  - `regard_angle` : angle du cône de vision en degrés
  - `corps_angle` : angle du corps en degrés
  - `vitesse` : vitesse appliquée au frame courant
- Enregistrés au démarrage du joueur, supprimés automatiquement à sa destruction
- **Fichiers :** `Scenes/Player/player.gd`

---

## Cycle jour/nuit progressif

- Overlay plein écran (`ColorRect` bleu nuit semi-transparent) superposé au monde de jeu
- Alpha 0 = plein jour, 0,85 = pleine nuit ; transitions progressives d'une durée d'1 heure de jeu (= 1 minute réelle)
- Chaque mission définit `sunrise` et `sunset` (format `"HH:MM"`) dans `missions.json`
- `_compute_night_alpha(game_hour)` : 4 phases — lever, plein jour, coucher, pleine nuit ; calcul ancré sur `since_rise = fmod(game_hour - sunrise + 24, 24)` pour gérer les rollovers minuit
- Les heures de lever/coucher sont stockées dans `Player_data.mission_sunrise_hour / mission_sunset_hour` et parsées au lancement de la mission
- **Fichiers :** `missions.json`, `UI/hud.tscn`, `UI/hud.gd`, `Scenes/Player/player_data.gd`, `UI/main_menu.gd`

---

## Menu radial au clic sur le personnage

- Clic gauche sur le sprite du joueur (rayon 26 px) → 6 boutons circulaires disposés en cercle (rayon 68 px)
- Actions disponibles : **B** Construire, **T** Ramasser, **Z** Parler, **C** Combat, **P** Fiche, **A** Attaquer
- Fermeture : clic sur une action (l'action est exécutée), clic en dehors (backdrop transparent), ou **Échap**
- Déplacement du joueur bloqué tant que le menu est visible
- Boutons circulaires générés dynamiquement avec `StyleBoxFlat` (corner radius = demi-diamètre)
- **Fichiers :** `UI/radial_menu.tscn`, `UI/radial_menu.gd`, `Scenes/Player/player.gd`

---

## Menus exclus du cycle nuit + pause automatique

- Le `NightOverlay` (HUD, layer 1) ne s'applique plus sur les menus Sheet, Settings et Home
- Fix : `character_sheet.tscn` et `MainMenuLayer` (main_menu.tscn) passés au **layer 10**, rendus après le HUD
- La fiche de personnage (Sheet) **pause** maintenant le jeu à l'ouverture et reprend à la fermeture (comportement identique à Settings et Home qui pausaient déjà)
- **Fichiers :** `UI/character_sheet.tscn`, `UI/main_menu.tscn`, `Scenes/Player/player.gd`

---

## Gel du temps de jeu pendant les menus

- L'horloge de mission est figée quand un menu est ouvert (Sheet, Settings, Home, menu radial)
- `hud.gd` détecte les transitions `get_tree().paused` bord montant/descendant et accumule la durée en pause dans `Player_data.mission_paused_duration`
- `_elapsed_real()` soustrait ce cumul au calcul de l'heure de jeu
- `mission_paused_duration` remis à 0 à chaque démarrage de mission
- **Fichiers :** `UI/hud.gd`, `Scenes/Player/player_data.gd`, `UI/main_menu.gd`

---

## Cône de vision pour les ennemis

- Chaque `RobotEnemy` détecte le joueur uniquement dans un cône de **120°** (±60°) en avant
- Cône affiché en rouge semi-transparent via `_draw()` (polygon + deux lignes de bordure)
- `facing_angle` mis à jour en temps réel quand le robot se déplace vers le joueur
- Masqué automatiquement quand le robot est mort (`is_dead`)
- **Fichiers :** `Objects/RobotEnemy/robot_enemy.gd`

---

## Écran de chargement stylisé

- Remplace la coupure nette entre scènes par un écran de chargement avec barre de progression animée
- Chargement asynchrone via `ResourceLoader.load_threaded_request()` ; statut sondé à chaque frame
- UI construite en code : titre doré "COMMANDO ZOMBI", sous-titre, lignes décoratives, barre verte, texte "CHARGEMENT..." animé (points de suspension)
- Fallback sur chargement synchrone en cas d'échec asynchrone
- **Fichiers :** `Autoload/scene_transition.gd`

---

## Indicateurs de cône et flèche masquables

- Option **Settings → Debug → Afficher le cône et la flèche** pour masquer/afficher les indicateurs visuels du joueur (cône vert + flèche orange)
- Contrôlé par `GameConfig.show_cone` (autoload), persisté dans `user://settings.json`
- Appliqué en temps réel via `if GameConfig.show_cone:` dans `_draw()` du joueur
- **Fichiers :** `Autoload/game_config.gd`, `UI/main_menu.tscn`, `UI/main_menu.gd`, `Scenes/Player/player.gd`

---

## Système de pilotage de Mecha (touche M)

- Le joueur peut monter dans un Mecha en approchant à portée et en appuyant sur **M**
- Label "M : Piloter" affiché sur le Mecha quand le joueur est à portée (`proximity_range`, défaut 50 px)
- **Montée** : sprites du joueur masqués, sa `CollisionShape2D` désactivée, la caméra zoome à ×0.8
- **Descente** : touche **M** à nouveau ; algorithme de position de sortie sûre (16 offsets testés via `PhysicsPointQueryParameters2D` pour éviter les murs) ; sprites et collisions restaurés
- **Déplacement avec inertie** : mouvement piloté par Flèches/WASD avec lissage exponentiel (`_smooth_velocity.lerp(target, inertia_factor * delta)`) — vitesse et facteur d'inertie configurables
- **Hitbox circulaire** : `CircleShape2D` centrée sur le mecha — rayon = `min(largeur, hauteur) / 2 × hitbox_scale` ; invariante à la direction (contrairement à un rectangle)
- **`@export hitbox_scale`** : facteur multiplicatif de hitbox réglable dans l'inspecteur Godot (défaut 2.0)
- **Collision murs** : `collision_layer = 4` (layer 3, mecha), `collision_mask = 1` (layer 1, TileMap) forcés dans `_ready()`
- **Orientation** : `facing_dir` (`Vector2`, public) mémorise la dernière direction de déplacement non-nulle ; l'avant du mecha = `facing_dir`, l'arrière = `-facing_dir`
- **Animations directionnelles** : `AnimatedSprite2D` avec sprite sheet 4×4 (`mecha_spider_sheet.png`, 187×101 px/frame, 748×404 total) — 4 animations : `walk_right`, `walk_left`, `walk_up`, `walk_down`, 4 frames chacune à 8 fps ; animation stoppée (frame figée) quand le mecha est à l'arrêt
- **Éjection orientée** : `_find_safe_exit_position()` teste en priorité l'arrière, puis les côtés relatifs à `facing_dir`, avant les offsets absolus
- **Cooldown anti-spam** : délai avant de pouvoir re-monter après une descente
- **Multi-mecha** : chaque Mecha possède un `mecha_id` unique, plusieurs Mechas coexistent par niveau
- **Configuration par JSON** : tous les paramètres sont optionnels dans `mechas.json` ; si absent, la valeur `@export` par défaut s'applique

  | Champ JSON | Propriété | Défaut |
  |---|---|---|
  | `speed` | `mecha_speed` | 120.0 |
  | `inertia` | `inertia_factor` | 6.0 |
  | `proximity` | `proximity_range` | 50.0 |
  | `hitbox_scale` | `hitbox_scale` | 2.0 |

- **CameraController** : suit la cible avec lerp (`LERP_SPEED = 5.0`) et zoome progressivement lors du pilotage (`MECHA_ZOOM = 0.8`, `DEFAULT_ZOOM = 1.0`) ; utilise `EventBus.player_mounted_mecha` / `player_dismounted_mecha`
- **Sauvegarde JSON** : positions des Mechas persistées dans `user://level_X/mechas.json` (priorité) → `res://Scenes/Levels/level_X/mechas.json` (fallback) ; chargement dans `base_level._load_mechas()`
- **Fichiers :** `Objects/Mecha/mecha.gd`, `Objects/Mecha/mecha.tscn`, `Autoload/CameraController.gd`, `Autoload/EventBus.gd`, `Scenes/Levels/base_level.gd`, `Scenes/Player/player.gd`, `Scenes/Player/player_data.gd`, `Lib/liblevel.gd`, `Scenes/Levels/level_1/mechas.json`

---

## Générateur de niveaux procédural (EditorScript)

- Script `res://Scripts/generate_level.py` — génère une carte ASCII aléatoire (200×100) avec salles et couloirs reliés
- Convention de caractères : `#` = sol (pièce / couloir), `S` = point de départ, `>` = sortie, ` ` = vide
- Script `res://Scripts/generate_level.gd` — EditorScript GDScript exécutable depuis Godot (**File › Run Script**)
- Lit `level_001.txt` (sortie du script Python) et génère un niveau Godot complet dans `Scenes/Levels/level_10/`
- Chaque caractère ASCII → bloc **8×8 tuiles natives** (16 px × 8 = 128 px par caractère, sans scale)
- Murs Godot (layer_1, collision) générés automatiquement : toute cellule vide adjacente à une cellule sol → bloc 8×8 de tuiles mur
- Met à jour `missions.json` : chemin de scène et spawn (centre de la tuile `S`, en pixels) pour `mission_10`
- Spawn positionné au centre du bloc `S` → garanti dans une salle ou un couloir
- **Fichiers :** `Scripts/generate_level.py`, `Scripts/generate_level.gd`, `Scripts/level_001.txt`, `Scenes/Levels/level_10/`, `missions.json`

---

## Indicateur visuel de l'heure (soleil / lune) sur le HUD

- Cadran circulaire dessiné via la classe interne `_SunMoonDial extends Control` avec `_draw()`
- Arc de fond sombre (360°) + arc doré entre les heures de lever et coucher définies par la mission (`sunrise` / `sunset`)
- Aiguille-point (cercle de 2,5 px) qui progresse de minuit (haut) à minuit dans le sens horaire
- Icône centrale : soleil (cercle jaune) de jour, croissant de lune (arc blanc) la nuit, gris si aucune mission active
- Arc de progression coloré : doré en journée, bleu lavande la nuit, depuis minuit jusqu'à l'heure courante
- Taille : 36×36 px, placé dans un `HBoxContainer` à gauche de l'étiquette de l'horloge
- Se redessine à chaque frame via `queue_redraw()` ; données lues depuis `_get_dial_data()` (Dictionary)
- **Fichiers :** `UI/hud.tscn`, `UI/hud.gd`

---

## Éditeur d'apparence en cours de partie

- Nouvel onglet **"Apparence"** dans la fiche de personnage (touche **P**)
- 8 slots modifiables : Corps, Cheveux, Couvre-chef, Bras, Gants, Torse, Jambes, Pieds
- Chaque slot affiche un `OptionButton` peuplé par `SpriteLibrary.get_slot_options(slot)` — ajouter un ZIP LPC = option automatiquement disponible
- Changements appliqués immédiatement en jeu via `_apply_appearance()` (signal `appearance_changed` émis par la fiche, reçu par `player.gd`)
- Sauvegardés instantanément dans `user://rpg.json` via `_auto_save_player()`
- La prévisualisation (SubViewport) est partagée avec l'onglet "Fiche" — `_stats_col` et `_app_panel` sont basculés en visibilité
- Feedback visuel "✓ Apparence sauvegardée" affiché 1,5 s après chaque changement
- Accès aux variables statiques de `Player_data` via `match` explicite (pas de `get()`) pour la sécurité de type
- **Fichiers :** `UI/character_sheet.tscn`, `UI/character_sheet.gd`, `Scenes/Player/player.gd`

---

## Option de désactivation de la musique intro / crédits

- Nouvelle case à cocher **"Musique intro / crédits"** dans **Settings → Audio**
- Stoppe la musique sur le splashscreen et la page de crédits quand décochée
- Paramètre `intro_music_enabled` stocké dans `GameConfig` (autoload) — chargé avant n'importe quelle scène, donc effectif dès l'apparition du splashscreen
- Persisté dans `user://settings.json` avec les autres réglages audio
- **Fichiers :** `Autoload/game_config.gd`, `UI/main_menu.tscn`, `UI/main_menu.gd`, `UI/splash_screen.gd`, `UI/credits.gd`

---

## Nom de personnage obligatoire dans le wizard de création

- Le bouton **"Suivant"** de la page 1 (Identité) est désactivé tant que le champ pseudo est vide
- Connexion au signal `text_changed` du `LineEdit` ; activation dès qu'un caractère est saisi
- Page 4 (Statistiques) s'ouvre avec **Santé = 10** par défaut (au lieu de 0)
- **Fichiers :** `UI/main_menu.gd`

---

## Système de sauvegarde multi-personnages

- Chaque personnage est sauvegardé dans son propre répertoire `user://characters/<slug>/`
- Slug généré automatiquement depuis le pseudo (minuscules, espaces/tirets → `_`, non-ASCII retirés)
- Fonctions centralisées dans `Player_data` : `set_character(slug)`, `character_dir()`, `level_save_dir(level_name)`
- Tous les chemins de sauvegarde (`rpg.json`, `mission_state.json`, `level_X/objects.json`, etc.) passent par ces helpers
- **Écran de sélection de personnage** : s'affiche au clic sur **Jouer** (avant la sélection de mission)
  - Liste les personnages existants avec nom et mission en cours
  - Si mission en cours : récapitulatif → reprendre ou choisir une autre mission
  - Si aucune mission : affiche directement la liste des missions
  - Bouton **"Nouveau personnage"** → wizard de création (Cancel retourne à la sélection)
- **Fichiers :** `Scenes/Player/player_data.gd`, `Lib/liblevel.gd`, `Scenes/Levels/base_level.gd`, `UI/main_menu.tscn`, `UI/main_menu.gd`, `UI/game_over.gd`

---

## Minimap avec brouillard de guerre

- Carte en coin inférieur droit (200×100 px) générée dynamiquement depuis les données de la TileMap
- Reçoit `EventBus.level_map_ready(floor_cells, map_scale)` émis par `base_level` après le spawn du joueur
- Rendu via `Image` + `ImageTexture` (un seul draw call par frame)
- **Brouillard de guerre** : cellules initialement en `COL_FLOOR_FOG` (gris foncé), révélées progressivement dans un rayon de 5 cellules autour du joueur (`COL_FLOOR_VIS`, gris clair)
- État visité persisté dans `Player_data.minimap_visited` (Dictionary), remis à zéro à chaque niveau
- `map_scale` : 128 px pour les niveaux générés (8 tuiles × 16 px), 16 px pour les niveaux natifs
- Toggle via l'action radiale **M — Carte** ; état persisté dans `Player_data.minimap_enabled`
- **Fichiers :** `UI/minimap.gd`, `UI/minimap.tscn`, `Autoload/EventBus.gd`, `Scenes/Levels/base_level.gd`, `Scenes/Player/player_data.gd`

---

## Zoom de la minimap au clic

- Clic gauche sur la minimap → agrandie à 600×400 px, centrée à l'écran (`CanvasLayer.layer = 20`)
- Deuxième clic → retour en minimap (200×100 px, coin inférieur droit, `layer = 5`)
- Mise à l'échelle transparente : le tracé joueur et la texture de carte sont mis à l'échelle via `ctrl.size` ; aucune image supplémentaire générée
- Curseur main sur la minimap (`CURSOR_POINTING_HAND`) pour signaler l'interaction
- **Fichiers :** `UI/minimap.gd`

---

## Modes de déplacement (touches 1 / 2 / 3)

- **Touche 1 — Marche** : vitesse normale (70 px/s aligné, 35 px/s sinon)
- **Touche 2 — Accroupi** : 20 px/s fixe quelle que soit l'orientation
- **Touche 3 — Course** : 130 px/s aligné, 55 px/s sinon
- Mode actuel affiché dans le HUD (panneau haut gauche) sous "Pos" : `"Mode: 1-Marche"` etc.
- État stocké dans `Player_data.movement_mode` (int 1/2/3)
- **Fichiers :** `Scenes/Player/player.gd`, `Scenes/Player/player_data.gd`, `UI/hud.tscn`, `UI/hud.gd`

---

## Restauration de la rotation du personnage au chargement

- `player_facing` était bien sauvegardé dans `rpg.json` à chaque auto-save mais jamais relu dans `load_game()`
- Le joueur se retrouvait systématiquement orienté vers le haut (direction par défaut) après reprise de partie
- Corrigé : `Player_data.player_facing = data.get("player_facing", 8)` ajouté dans `liblevel.load_game()`
- **Fichiers :** `Lib/liblevel.gd`

---

## Mode tir — Viseur et ligne de tir

- Nouvelle action **"F — Tirer"** dans le menu radial ; toggle activation / désactivation
- **Réticule** : cercle rouge (Ø 44 px) avec 4 branches et point central, dessiné en espace écran (`CanvasLayer layer = 15`) via la classe interne `_CrosshairDraw`
- Le curseur OS est masqué en mode tir ; restauré à la fermeture du menu radial ou à la destruction du nœud
- **Ligne de tir** : tracée du centre du joueur au réticule (en espace écran via `canvas_transform`)
  - Si la ligne intersecte un mur (raycast physique couche 1, joueur exclu) : la ligne s'arrête au point d'impact ; le réticule reste affiché à la position de la souris
  - Si le réticule est **hors du cône de vision** (±45° de `look_angle`) : la ligne n'est pas tracée
- Raycast calculé dans `_process` (`_update_aim_line()`), résultat stocké dans `_CrosshairDraw` pour le dessin
- Les boutons du HUD (Fiche / Armurerie / Paramètres / Accueil) sont désactivés tant que le mode tir est actif
- **Fichiers :** `Scenes/Player/player.gd`

---

## Plein écran automatique au lancement

- Le jeu s'ouvre directement en plein écran (mode fenêtre sans bordures) quel que soit le bureau
- `window/size/mode=3` (borderless fullscreen) dans `project.godot`
- `window/stretch/mode="viewport"` + `window/stretch/aspect="keep"` : contenu rendu à la résolution conçue, bandes noires sur les côtés si le ratio de l'écran diffère
- **Fichiers :** `project.godot`

---

## Panoramique caméra (Shift + directions)

- Maintenir **Shift** + touches de direction (Flèches / WASD) déplace la vue indépendamment du joueur
- Le joueur reste immobile pendant le panoramique (son déplacement est bloqué quand Shift est enfoncé)
- Retour automatique doux vers le joueur à la relâche de Shift (lerp `PAN_RETURN_SPEED = 8.0`)
- **Limite dynamique** : le décalage est plafonné aux bords de l'écran — le personnage peut atteindre exactement le bord gauche/droit/haut/bas
  - `half_w = viewport.size.x / (camera.zoom.x × 2)`, `half_h = viewport.size.y / (camera.zoom.y × 2)`
  - Clamp par axe via `clampf()` pour préserver la liberté dans l'autre direction
- `_pan_offset: Vector2` ajouté à la position cible dans `_process` de `CameraController`
- **Fichiers :** `Autoload/CameraController.gd`, `Scenes/Player/player.gd`

---

## Son moteur du Mecha

- `AudioStreamPlayer2D` (nœud `EngineSound`) ajouté au Mecha avec `autoplay = false`
- Fichier OGG : `res://Sounds/effect/battle-mech-walks.ogg`, mis en boucle au démarrage via `(stream as AudioStreamOggVorbis).loop = true`
- Démarré quand le mecha se déplace (`input_dir != Vector2.ZERO`), arrêté à l'arrêt ou à la descente du pilote
- Volume géré par `GameConfig.sfx_enabled` / `linear_to_db(GameConfig.sfx_volume_linear)` — même pattern que les pas du joueur
- `_update_engine_sound(moving: bool)` centralise la logique démarrage / arrêt / volume
- **Fichiers :** `Objects/Mecha/mecha.tscn`, `Objects/Mecha/mecha.gd`

---

## Référence — Statistiques de l'armurerie

Chaque équipement de l'armurerie possède des statistiques communes et des statistiques spécifiques à sa catégorie. Voici la signification de chaque champ.

### Statistiques communes (toutes catégories)

| Champ | Signification |
|---|---|
| `name` | Nom complet de l'équipement affiché dans l'interface |
| `model` | Désignation constructeur / modèle |
| `version` | Variante ou version du modèle |
| `category` | Catégorie interne : `weapon`, `armor`, `gadget`, `clothing` |
| `description` | Texte descriptif affiché dans la fiche de détail |
| `weight` | Masse de l'équipement en kilogrammes — influence la capacité de charge utilisée |
| `price` | Coût d'achat en crédits (¤) — déduit de `player_credit` à l'achat |

---

### Armes (`Armory/weapons.json`)

| Champ | Signification |
|---|---|
| `damage` | Points de dégâts infligés à l'ennemi par tir ou coup réussi |
| `precision` | Score de précision (échelle 1–10) : plus la valeur est élevée, plus la chance de toucher est grande — comparé à `player_precision` lors du jet de dés |
| `range` | Portée effective de l'arme en mètres — au-delà, les tirs subissent une pénalité |
| `fire_rate` | Cadence de tir en coups par minute — influence la rapidité des échanges |
| `reload_time` | Durée de rechargement en secondes — pendant ce temps le joueur est vulnérable |
| `magazine_size` | Nombre de munitions par chargeur avant rechargement obligatoire |
| `noise` | Niveau sonore produit à chaque tir (échelle 1–10) — une valeur élevée alerte les ennemis à plus grande distance |
| `recoil` | Recul produit lors du tir (échelle 1–10) — une valeur élevée dégrade la précision des tirs rapides successifs |
| `mobility_penalty` | Malus de vitesse de déplacement (points soustraits à la vitesse de base) — les armes lourdes ralentissent le joueur |
| `stealth_modifier` | Modificateur de discrétion : valeur négative = l'arme trahit la position du joueur ; valeur positive = l'arme aide à rester discret |
| `fire_modes` | Liste des modes de tir disponibles : `semi` (semi-automatique), `auto` (automatique), `burst` (rafale), `bolt_action` (verrou, un coup à la fois), `melee` (corps-à-corps) |
| `ammo_type` | Type de munitions requis (ex. `5.56mm`, `9mm`, `12 gauge`) — détermine la compatibilité avec les approvisionnements |
| `can_attach_silencer` | `true` si un silencieux peut être monté — réduit le bruit et le modificateur de discrétion |

---

### Protections (`Armory/protections.json`)

| Champ | Signification |
|---|---|
| `defense` | Bonus de défense ajouté à `player_defense` — augmente la résistance aux attaques ennemies lors des jets de défense |
| `damage_reduction` | Pourcentage de réduction des dégâts reçus (ex. `0.20` = 20 %) — appliqué à chaque coup encaissé |
| `mobility_penalty` | Malus de vitesse (points soustraits) — les armures lourdes ralentissent significativement le joueur |
| `noise_increase` | Augmentation du bruit émis lors des déplacements — une armure bruyante compromet les approches discrètes |
| `stealth_penalty` | Malus de discrétion : rend le joueur plus facilement détectable par les ennemis |

---

### Matériel (`Armory/gears.json`)

| Champ | Signification |
|---|---|
| `effect` | Identifiant de l'effet spécial déclenché à l'utilisation — valeurs possibles : |
| | `reveal_enemies` — révèle la position des ennemis à proximité sur la carte |
| | `night_vision` — active la vision nocturne (réduit l'impact de l'obscurité) |
| | `thermal_detection` — détection thermique des ennemis à travers les obstacles |
| | `stun_enemies` — étourdit les ennemis dans le rayon d'action pendant la durée |
| | `smoke_screen` — crée un écran de fumée bloquant la ligne de vue ennemie |
| | `heal_player` — soigne le joueur d'un nombre de PV déterminé |
| | `unlock_silent` — permet de crocheter une serrure sans bruit |
| | `breach_door` — force l'ouverture d'une porte verrouillée |
| | `disable_electronics` — désactive temporairement les appareils électroniques proches |
| | `squad_coordination` — améliore temporairement les statistiques du groupe |
| `detection_radius` | Rayon d'action de l'effet en mètres — zone affectée autour du joueur lors de l'activation |
| `duration` | Durée d'activation de l'effet en secondes — au-delà le gadget doit recharger |
| `cooldown` | Temps de recharge en secondes entre deux utilisations consécutives |

---

### Vêtements (`Armory/clothes.json`)

| Champ | Signification |
|---|---|
| `stealth_bonus` | Bonus de discrétion ajouté à `player_stealth` — rend le joueur plus difficile à détecter |
| `mobility_bonus` | Bonus de vitesse de déplacement — les tenues légères améliorent l'agilité |
| `noise_reduction` | Réduction du bruit émis lors des déplacements — crucial pour les approches silencieuses |
| `visibility_reduction` | Réduction de la visibilité du joueur aux yeux des ennemis (camouflage visuel) |
| `temperature_resistance` | Résistance aux conditions climatiques extrêmes (chaleur, froid) — influence la stamina dans les environnements hostiles |
| `defense` | Bonus de défense — certaines tenues offrent une protection physique légère |
| `mobility_penalty` | Malus de vitesse — certains équipements encombrants (gilets tactiques, combinaisons) ralentissent le joueur |
| `noise_increase` | Augmentation du bruit — certains matériaux (cuir rigide, équipements métalliques) produisent du son |
| `stealth_penalty` | Malus de discrétion — certaines tenues aux couleurs vives ou matériaux réfléchissants trahissent la position |

---

### Correspondance affichage → clé JSON

Le tableau suivant relie le label affiché dans l'interface (onglet Armurerie et popup de détail) à la clé JSON correspondante.

| Affiché | Clé JSON | Catégorie |
|---|---|---|
| Dégâts | `damage` | Arme |
| Précision | `precision` | Arme |
| Portée (m) | `range` | Arme |
| Cadence (cps/min) | `fire_rate` | Arme |
| Rechargement (s) | `reload_time` | Arme |
| Capacité chargeur | `magazine_size` | Arme |
| Bruit | `noise` | Arme |
| Recul | `recoil` | Arme |
| Modes de tir | `fire_modes` | Arme |
| Munitions | `ammo_type` | Arme |
| Silencieux possible | `can_attach_silencer` | Arme |
| Défense | `defense` | Protection / Vêtement |
| Réduction dégâts | `damage_reduction` | Protection |
| Effet | `effect` | Matériel |
| Rayon (m) | `detection_radius` | Matériel |
| Durée (s) | `duration` | Matériel |
| Recharge (s) | `cooldown` | Matériel |
| Bonus discrétion | `stealth_bonus` | Vêtement |
| Bonus mobilité | `mobility_bonus` | Vêtement |
| Réduction bruit | `noise_reduction` | Vêtement |
| Réduction visibilité | `visibility_reduction` | Vêtement |
| Résistance température | `temperature_resistance` | Vêtement |
| Pénalité mobilité | `mobility_penalty` | Arme / Protection / Vêtement |
| Pénalité discrétion | `stealth_penalty` | Protection / Vêtement |
| Mod. discrétion | `stealth_modifier` | Arme |
| Augmentation bruit | `noise_increase` | Protection / Vêtement |
| Poids | `weight` | Toutes |
| Prix | `price` | Toutes |
