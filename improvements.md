# Improvements — Commando Zombi RPG v4

Ce fichier regroupe les pistes d'amélioration futures et l'historique des améliorations déjà apportées.

---

## Pistes d'amélioration futures

### Gameplay

#### Système de santé fonctionnel
- Ajouter des zones de dégâts (pièges, sols radioactifs) qui réduisent la santé au contact
- La santé est réduite par les `RobotEnemy` mais le HUD ne change pas de couleur / aucune réaction visuelle côté joueur

#### Objets de soin
- Nouveau type d'objet collectable (`health_item`) qui restaure 1 point de santé
- Même système d'interaction que les ordinateurs et robots (T pour ramasser)
- Max santé : utiliser `player_health_base` comme plafond (valeur définie à la création du personnage)

#### Effets de spécialisation sur le gameplay
- La spécialisation choisie à la création pourrait modifier les stats ou débloquer des capacités
- Exemples : Médecin de combat → récupère +1 PV après un combat gagné ; Tireur de précision → bonus d'attaque à distance

#### Objectifs de mission intégrés au HUD
- Afficher les objectifs de la mission active en cours de partie (panneau rétractable ou coin d'écran)
- Alimenté par `missions.json`, persisté dans `Player_data` ou un autoload dédié
- Objectifs cochables : déclencher un événement (ouverture de porte, transition) à la complétion

#### Progression et état des missions
- Mémoriser quelle mission est en cours (`user://current_mission.json`)
- Marquer les missions comme terminées, afficher un récapitulatif en fin de mission
- Débloquer les missions suivantes selon la progression

#### Portes et clés
- Ajouter des objets `door` bloquant le passage entre zones
- Une clé (`key_item`) collectée via T déverrouille la porte correspondante
- État ouvert/fermé persisté dans le JSON du niveau

#### Expérience et niveaux du joueur
- Gagner des XP en tuant des robots ennemis
- Seuils de niveau : augmentent `player_attack` ou `player_defense` automatiquement
- Affiché dans la fiche de personnage (touche P)

#### Dialogues persistants
- Mémoriser les choix déjà faits pour chaque PNJ (`user://npc_state.json`)
- Permettre à un PNJ de donner un objet ou d'ouvrir une porte selon les réponses du joueur

---

### Interface utilisateur

#### Tutoriel / première fois
- Détecter si c'est la première partie (`user://rpg.json` absent)
- Afficher des bulles d'aide contextuelles (ex. : "Appuyez sur T pour ramasser")
- Disparaissent après la première utilisation de chaque action

#### Fiche de personnage enrichie
- Afficher le grade, la spécialisation et la biographie dans la fiche (touche P)
- La biographie pourrait apparaître dans un onglet ou un panneau dédié

#### Indicateur de santé visuel
- Le HUD change de couleur (vert → orange → rouge) selon les PV restants
- Flash rouge sur les bords de l'écran quand le joueur prend un coup

#### Journal de quête
- Panneau accessible depuis le HUD listant les objectifs actifs et complétés
- Alimenté par un fichier JSON de quête par niveau

---

### Génération procédurale de niveaux

#### Génération reproductible (seed)
- Passer un `seed` fixe à `RandomNumberGenerator` dans `generate_level.py` pour obtenir des maps identiques entre deux runs
- Stocker le seed dans le JSON exporté et dans `missions.json` pour pouvoir recréer la carte à la demande

#### Difficulté paramétrable par niveau
- Exposer `max_rooms`, `base_w`, `base_h` comme paramètres de `generate_level()` dans le script Python
- Augmenter la densité de salles / la taille pour les niveaux avancés (level_11+)

#### Génération de niveaux 5–9
- Actuellement seul `level_10` utilise `generate_from_file()`
- Étendre le script GDScript pour accepter n'importe quel numéro de niveau et fichier `.txt` associé
- Permettre de rejouer la génération sans écraser la scène existante (option `--force`)

#### Placement automatique d'objets dans les salles
- Le script Python connaît déjà les positions de toutes les salles (`rooms[]`)
- Placer automatiquement des objets (ordinateurs, robots, ennemis) dans des salles aléatoires
- Exporter leurs positions dans `level_001.json` → le script GDScript les instancie dans la scène

#### Marqueur de sortie `>` comme transition réelle
- Le caractère `>` est positionné dans le fichier `.txt` mais n'est pas encore converti en `entrance_y_2` / zone de transition
- Créer un nœud `Area2D` à la position du `>` et connecter son signal `body_entered` pour changer de scène

#### Minimap générée depuis la TileMap
- Le générateur connaît la structure exacte (salles, couloirs) — utiliser ces données pour dessiner une minimap en temps réel
- Afficher les salles visitées vs non visitées (brouillard de guerre)

#### Export multi-niveaux en une passe
- Ajouter un mode batch au script GDScript : lire une liste de fichiers `.txt` et générer plusieurs `.tscn` en séquence
- Utile pour pré-générer 5–10 niveaux aléatoires avant une session de jeu

---

### Technique

#### Sons d'effets
- Son de collecte quand T est pressé sur un objet
- Son de poussée quand R est pressé
- Son de dégâts si un ennemi touche le joueur

#### Animations des objets
- Animation d'apparition pour les objets spawnés (scale de 0 à 1)
- Animation de disparition avant `queue_free()` lors de la collecte

#### Musique par niveau
- Chaque niveau joue une piste musicale différente
- Transition en fondu entre les pistes au changement de zone
- Le volume respecte le slider de la page Audio

#### Pool d'objets pour les ennemis
- Au lieu de `queue_free()` + `instantiate()`, recycler les instances de `RobotEnemy`
- Améliore les performances sur les niveaux avec beaucoup d'ennemis

---

### Combat

#### Fuite avec dés
- La fuite (touche C en combat) utilise encore un tirage interne sans overlay CombatUI
- À améliorer pour afficher le dé de fuite dans l'overlay et attendre Espace

#### Équilibrage du combat
- Avec le wizard de création, le joueur peut allouer 0–30 points en attaque/défense — la plage effective est donc beaucoup plus large qu'avant (anciennement 10–15 fixe)
- Envisager des valeurs minimales par stat (ex. : min 5) pour éviter un personnage déséquilibré (tout en santé, 0 en attaque)
- Calibrer la difficulté des ennemis en fonction des nouvelles plages possibles

---

### Apparence du personnage

#### Sprites LPC supplémentaires
- Enrichir les options de chaque slot au fil des imports (nouvelles couleurs de peau, coiffures, armures…)
- Procédure : copier les PNG extraits dans `Sprites/Player/items/`, ouvrir Godot (import auto), lancer `bash Scripts/update_sprite_index.sh`, mettre à jour `character.json` — voir `Docs/lpc_sprites.md`

#### Sprite LPC pour les PNJ et ennemis
- Utiliser le même système de layers LPC pour habiller les PNJ et les `RobotEnemy`
- Permet une variété visuelle sans créer de nouvelles textures manuellement

---

### Cône de vision

#### Impact du cycle jour/nuit sur la détection
- La nuit : portée de détection des ennemis réduite (visibilité diminuée pour tout le monde)
- Complète logiquement le cycle jour/nuit déjà en place

---

### Cycle jour/nuit

#### Couleur de l'overlay selon l'heure
- Coucher de soleil : teinte orangée avant de passer au bleu nuit
- Aube : teinte violacée / rosée avant le retour au blanc
- Implémenter via `lerp` sur la couleur de `NightOverlay` en plus de l'alpha

#### Impact gameplay de la nuit
- Ennemis plus nombreux ou plus rapides entre 22h00 et 05h00
- Zones sûres uniquement accessibles le jour (portes verrouillées la nuit)

---

### Mode tir

#### Tir effectif
- Déclencher un projectile ou un hitscan au clic gauche quand le viseur est actif et la ligne visible
- Dégâts basés sur `player_attack` ; portée limitée par la distance max du raycast

#### Munitions et rechargement
- Compteur de munitions affiché dans le HUD pendant le mode tir
- Rechargement automatique ou via une touche dédiée ; animation de rechargement

#### Indicateur visuel de la zone de tir
- Colorier le réticule différemment selon l'état : vert = dans le cône (tir possible), gris = hors cône (tir impossible)
- Petit texte ou icône indiquant "HORS PORTÉE" quand un mur bloque à moins de X px du joueur

#### Couche physique configurable
- Actuellement le raycast utilise la couche 1 — prévoir un paramètre `GameConfig.aim_ray_mask` pour s'adapter à d'autres configurations de physique

---

### Menu radial

#### Support manette / gamepad
- Maintenir un bouton de la manette pour ouvrir le menu radial
- Navigation au stick analogique gauche pour sélectionner l'action mise en surbrillance
- Relâcher le bouton confirme l'action sélectionnée

---

### Mecha

#### Armement du Mecha
- Ajouter une arme intégrée au Mecha (mitrailleuse, lance-roquettes) déclenchée par une touche dédiée
- Dégâts et portée supérieurs au combat à pied ; munitions limitées par mission

#### Santé et destruction du Mecha
- Le Mecha accumule des dégâts reçus (ennemis, mines, pièges)
- Quand la santé du Mecha tombe à 0, le joueur est éjecté et le Mecha est détruit (inutilisable jusqu'à réinitialisation)
- Afficher la santé du Mecha dans le HUD pendant le pilotage

#### Mecha multi-joueur / mission
- Certaines missions pourraient nécessiter le Mecha pour franchir des zones (obstacles, distances)
- Un Mecha cassé bloque l'accès à ces zones → encourage à l'utiliser avec précaution

#### Variantes de Mecha
- Plusieurs types de Mechas (léger / lourd) avec vitesse, hitbox et armement différents
- Type défini par `mecha_type` dans `mechas.json`

#### Son du Mecha
- Son d'impact quand le Mecha heurte un mur

---

### Jeu en équipe

#### 1. Mini-portraits de l'équipe dans le HUD
Afficher une barre horizontale compacte en bas ou en haut de l'écran, avec un mini-portrait par membre :
- Indicateur de santé sous chaque portrait (barre ou fraction)
- Surbrillance du portrait du personnage actif
- Clic sur un portrait = switch vers ce personnage (équivalent Shift+N)
- Grisé + icône ☠ si le membre est mort

**Fichiers concernés :** `UI/hud.tscn`, `UI/hud.gd`, `Scenes/Player/player.gd`

---

#### 2. Indicateur hors-écran des membres inactifs
Quand un membre de l'équipe se trouve hors des limites de l'écran, afficher une petite flèche colorée (couleur du slot) sur le bord de l'écran pointant vers sa position — comme un radar de bord.

**Implémentation suggérée :** `CanvasLayer` sur la caméra active ; calcul de direction `world_to_screen()` → si hors viewport, projeter sur le bord et placer une `Polygon2D` triangle.

**Fichiers concernés :** `Scenes/Player/player.gd` (actif) ou nouveau `UI/party_compass.gd`

---

#### 3. Mode suivi automatique pour les membres inactifs
Ajouter un toggle (raccourci ou menu radial) pour que les membres inactifs suivent automatiquement le personnage actif à distance fixe (formation). En mode suivi :
- Chaque inactif se déplace vers la position du chef avec un `NavigationAgent2D` ou un lerp simple
- Ils conservent leur propre `CollisionShape2D` pour ne pas traverser les murs
- Un offset par slot évite qu'ils se superposent (ex. : −40 px à gauche, +40 px à droite)

**Fichiers concernés :** `Scenes/Player/player.gd` (inactif, `_physics_process`), `EventBus.gd` (signal position chef), `Autoload/player_data.gd` (flag `party_follow_mode`)

---

#### 4. Partage de ressources entre membres
Option pour que les crédits et l'inventaire soient partagés entre tous les membres de l'équipe plutôt qu'individuels :
- `PartyData` exposerait `shared_credits` et `shared_inventory`
- Achats à l'armurerie débitent le pool commun
- Collectes incrémentent le pool commun
- Activable/désactivable depuis le gestionnaire de personnages

**Fichiers concernés :** `Scenes/Player/party_data.gd`, `UI/armory.gd`, `Scenes/Player/player.gd`

---

#### 5. Assistance au combat par les membres inactifs
Quand le personnage actif engage un combat, les membres inactifs à portée participent passivement :
- Bonus de dés (ex. : +2 à l'attaque ou la défense) selon les stats de chaque allié présent
- Message dans le `CombatUI` : *"[Nom] vous couvre — Défense +2"*
- Portée configurable (ex. : 80 px)

**Fichiers concernés :** `Scenes/Player/player.gd` (`_start_combat()`), `UI/combat_ui.gd`, `Scenes/Player/party_data.gd`

---

#### 6. Statut de mission partagé dans le récapitulatif
Sur l'écran de récapitulatif de mission, afficher une ligne par membre de l'équipe avec sa contribution (ex. : ordinateurs collectés, ennemis vaincus, distance parcourue).

**Implémentation suggérée :** tracker par slot dans `PartyData` (`kills`, `objects_collected`, `distance`) ; section "Équipe" dans `_show_mission_recap()`.

**Fichiers concernés :** `Scenes/Player/party_data.gd`, `UI/main_menu.gd`

---

## Améliorations apportées

### Détection de partie du corps — recalibration pixel-précise

**Problème initial :** les seuils verticaux de `_body_part_at()` utilisaient des offsets fixes en pixels sans tenir compte des dimensions réelles du sprite ni du transform complet de l'entité.

**Améliorations apportées :**
- Remplacement de `world_pos - entity.global_position` par `entity.global_transform.affine_inverse() * world_pos` : gère la rotation, l'échelle et la translation de l'entité
- Lecture des dimensions exactes du frame via `spr.texture.get_size() / hframes / vframes` et prise en compte de `spr.scale`
- Calibrage des seuils via analyse pixel du frame LPC 64×64 (`idle_down`, frame 130)
- Bras détectés dans la bande `0 à +20` si `|lx| > frame_w * 0.17`

**Fichiers :** `Scenes/Player/player.gd`

---

### Sauvegarde des PNJ — robustesse multi-callsite

**Problème initial :** trois appelants de `liblevel.saveAllObjects()` ne passaient pas la liste des PNJ, ce qui écrasait `npcs.json` avec un tableau vide.

**Améliorations apportées :**
- Signature de `saveAllObjects()` étendue avec le paramètre `npcs = []`
- Les trois callsites passent désormais `get_tree().get_nodes_in_group("npc")`
- `reinitializeLevel()` inclut `"npcs.json"` dans la liste des fichiers à supprimer
- Vérification null-safe sur `FileAccess.open()` avant écriture de `npcs.json`

**Fichiers :** `Lib/liblevel.gd`, `Scenes/Player/player.gd`, `Scenes/Levels/base_level.gd`, `UI/main_menu.gd`

---

### Chargement des PNJ — application de l'état mort

**Problème initial :** `apply_dead_state()` était appelé via `call_deferred`, avant que les nœuds `@onready` ne soient disponibles.

**Amélioration apportée :** l'appel à `apply_dead_state()` est déplacé dans `npc.setup()`, exécuté après `add_child()`.

**Fichiers :** `Objects/NPC/npc.gd`, `Scenes/Levels/base_level.gd`

---

### Mode d'affichage — passage en mode fenêtré

**Amélioration apportée :**
- `window/size/mode=0` (fenêtré) dans `project.godot`
- `window/stretch/mode="canvas_items"` + `window/stretch/scale_mode="integer"` : pas de flou, mise à l'échelle entière

**Fichiers :** `project.godot`

---

### Option de debug — visibilité de la ligne de tir

**Amélioration apportée :**
- Case à cocher **"Afficher la ligne rouge de la cible"** dans **Settings → Debug**
- Contrôlée par `GameConfig.show_aim_line`, persistée dans `user://settings.json`

**Fichiers :** `Autoload/game_config.gd`, `UI/main_menu.tscn`, `UI/main_menu.gd`, `Scenes/Player/player.gd`

---

### Page Vidéo — connexions signal branchées programmatiquement

**Problème initial :** les connexions ajoutées manuellement dans le `.tscn` pour les boutons Vidéo/Appliquer/Retour n'étaient pas prises en compte.

**Amélioration apportée :** branchement dans `_connect_video_settings()` appelé depuis `_ready()` avec `is_connected()` pour éviter les doublons.

**Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`

---

### Page Vidéo — gestion de la limitation mode éditeur

**Problème initial :** `DisplayServer.window_set_mode(WINDOW_MODE_FULLSCREEN)` est refusé dans la fenêtre embarquée de l'éditeur.

**Amélioration apportée :**
- Détection via `OS.has_feature("editor")` : le changement de mode est sauté mais la préférence est écrite dans `user://settings.json`
- `LabelHint` (orange) affiché sur le panel Vidéo en mode éditeur

**Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`

---

### Armurerie — affichage image à hauteur fixe (TextureRect)

**Solution retenue :**
- `expand_mode = 1` (IGNORE_SIZE) + `stretch_mode = 5` (KEEP_ASPECT_CENTERED)
- `size_flags_vertical = 0` + `custom_minimum_size = Vector2(0, 180)`

**Fichiers :** `UI/armory.tscn`

---

### Vision nocturne — shader : `return` interdit dans `fragment()`

**Amélioration apportée :** `return` remplacé par un `if/else` équivalent — pixels hors-cône reçoivent la couleur originale, pixels dans le cône reçoivent le filtre NVG.

**Fichiers :** `Shaders/night_vision.gdshader`

---

### HUD — largeur du ClockPanel HBox fixée à 200 px

**Amélioration apportée :** `custom_minimum_size = Vector2(200, 0)` ajouté sur le nœud `HBox` de `ClockAnchor/ClockPanel`.

**Fichiers :** `UI/hud.tscn`

---

### Système multi-personnages — persistance et restauration des positions

**Problèmes initiaux (plusieurs bugs cumulés) :**
1. `save_party()` n'enregistrait que les slugs — aucune position ni stat des membres non-actifs
2. `save_full_party()` ne lisait pas les nœuds inactifs → leurs positions n'étaient jamais mises à jour
3. `load_party()` n'était jamais appelé au démarrage → `PartyData.slots` vide à chaque lancement
4. `_on_cs_play_pressed()` appelait `setup_solo()` inconditionnellement, écrasant l'équipe sauvegardée
5. `active_slot` n'était jamais remis à 0 au clic "Jouer"
6. `_spawn_party()` utilisait toujours `rpg.json` pour le slot actif, ignorant la position de `party.json`

**Améliorations apportées :**
- `save_party()` : enregistre le dict `data` complet (`pos_x`, `pos_y`, toutes les stats) pour chaque slot
- `save_full_party()` : snapshot du slot actif depuis `Player_data` ; slots inactifs mis à jour depuis `PartyData.get_node_at(i).global_position`
- `load_party()` : restaure le dict `data` depuis le JSON ; appelé dans `main_menu._ready()` si `slot_count() == 0`
- `_update_slot0_preserving_pos()` : nouvelle fonction — préserve `pos_x/pos_y` existants avant de remplacer le dict du chef
- `_spawn_party()` : utilise `party.json` pour le slot actif si disponible ; repli sur `_place_player()` sinon

**Fichiers :** `Scenes/Player/party_data.gd`, `Scenes/Levels/base_level.gd`, `UI/main_menu.gd`

---

### Jeu en équipe — fonctionnalités implémentées

#### Santé individuelle par personnage *(implémenté)*
Chaque membre de l'équipe possède ses propres stats (santé, mouvement, etc.) sauvegardées dans son `rpg.json` individuel au moment du switch.

**Fichiers :** `Scenes/Player/player_data.gd`, `Scenes/Levels/base_level.gd`

---

#### Cooldown de switch avec animation de transition *(implémenté)*
Flash noir (0,15 s fondu sortant + 0,25 s fondu entrant) au moment du switch ; cooldown de 1,5 s ; flash orange si tentative pendant le cooldown.

**Fichiers :** `Scenes/Levels/base_level.gd`

---

#### Transfert d'équipement entre membres *(implémenté)*
Panneau "Transfert d'équipement ↔" dans le gestionnaire de personnages et dans la barre HUD. Dropdowns FROM/TO, liste des objets avec bouton "Transférer".

**Fichiers :** `UI/main_menu.gd`, `UI/hud.tscn`, `UI/hud.gd`, `Scenes/Player/player.gd`

---

### Création de personnage — variable `name` renommée en `entry`

**Problème initial :** warning `SHADOWED_VARIABLE_BASE_CLASS` sur `main_menu.gd` — la variable locale `name` masquait `Node.name`.

**Amélioration apportée :** variable locale renommée `entry` dans la boucle `DirAccess` de `_delete_dir_recursive()`.

**Fichiers :** `UI/main_menu.gd`

---

### Menu principal — bouton Gérer cliquable en cours de partie

**Problème initial :** le bouton **Gérer** sur l'écran de sélection de personnage n'était pas cliquable quand le jeu était en pause (`get_tree().paused = true`).

**Améliorations apportées :**
- `process_mode = Node.PROCESS_MODE_ALWAYS` ajouté au début de `_ready()` dans `main_menu.gd` — le menu reste réactif même quand l'arbre est mis en pause
- Isolation des panneaux : `_on_button_play_pressed()` masque tous les panneaux secondaires avant d'afficher `character_select` ; `_on_cs_back_pressed()` masque `mission_select` avant de revenir à l'écran de sélection

**Fichiers :** `UI/main_menu.gd`

---

### Export web — SpriteLibrary réécrite (`ZIPReader` → `load()` + `sprite_index.json`)

**Problème initial :** à l'export web, aucun graphisme n'apparaissait dans la création de personnage. Deux causes cumulées : `DirAccess.open("res://…")` renvoie `null` dans les exports web (le PCK est un système de fichiers virtuel plat, non itérable) ; les archives ZIP n'ont pas de fichier `.import` et sont silencieusement exclues par `export_filter="all_resources"`.

**Améliorations apportées :**
- `SpriteLibrary` entièrement réécrit : plus de `ZIPReader` ni de `DirAccess` — les textures sont chargées via `load()` directement depuis `Sprites/Player/items/`
- `sprite_index.json` créé : liste statique des noms de PNG présents dans `items/` — remplace le scan de répertoire, inclus dans tous les exports comme fichier texte importé normalement par Godot
- `_load_catalogue()` lit `character.json` (catalogue LPC) + `sprite_index.json`, puis charge chaque texture avec `ResourceLoader.exists()` + `load()`
- Script bash `Scripts/update_sprite_index.sh` créé pour régénérer `sprite_index.json` automatiquement après ajout ou retrait de PNG

**Fichiers :** `Autoload/sprite_library.gd`, `Sprites/Player/sprite_index.json`, `Scripts/update_sprite_index.sh`

---

### Export web — mise à l'échelle fractionnaire + hauteur du ScrollContainer

**Problème initial :** sur la version web, la page "Gestion des personnages" débordait en bas — le bouton "Retour" était visible en dehors de la zone de jeu. Causes : `ScrollContainer.custom_minimum_size = Vector2(0, 340)` rendait le panneau trop haut avec 5 membres, et `scale_mode="integer"` empêchait une mise à l'échelle sub-entière quand le chrome du navigateur réduisait la hauteur disponible sous 720 px.

**Améliorations apportées :**
- `window/stretch/scale_mode` passé de `"integer"` à `"fractional"` dans `project.godot` — permet tout ratio de mise à l'échelle sur web
- `ScrollContainer.custom_minimum_size` réduit de 340 à 160 px dans `_build_character_manager_panel()` — le panneau total reste sous les 720 px avec 5 membres

**Fichiers :** `project.godot`, `UI/main_menu.gd`

---

### `level_3.tscn` — suppression du nœud orphelin `level_2_11_20`

**Problème initial :** erreur à l'export — `Parse Error: res://Scenes/Levels/level_3/level_3.tscn:5206` — due à une référence vers `ExtResource("3_mwivg")` non déclaré.

**Cause :** le commit `55319f1` avait supprimé la déclaration `[ext_resource … id="3_mwivg"]` (entrance_y_2.tscn) de l'en-tête du fichier mais avait laissé le nœud `[node name="level_2_11_20" instance=ExtResource("3_mwivg")]` et sa ligne `position` en fin de fichier.

**Amélioration apportée :** les deux lignes orphelines ont été supprimées de `level_3.tscn`.

**Fichiers :** `Scenes/Levels/level_3/level_3.tscn`
