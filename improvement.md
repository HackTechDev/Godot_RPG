# Improvements — Commando Zombi RPG v4

Améliorations apportées à des fonctionnalités existantes.

---

## Détection de partie du corps — recalibration pixel-précise

**Problème initial :** les seuils verticaux de `_body_part_at()` utilisaient des offsets fixes en pixels (`-20, -2, +8, +20`) issus d'estimations, sans tenir compte des dimensions réelles du sprite ni du transform complet de l'entité.

**Améliorations apportées :**

- Remplacement de `world_pos - entity.global_position` par `entity.global_transform.affine_inverse() * world_pos` : gère la rotation, l'échelle et la translation de l'entité
- Lecture des dimensions exactes du frame via `spr.texture.get_size() / hframes / vframes` et prise en compte de `spr.scale`
- Analyse pixel du frame LPC 64×64 (`idle_down`, frame 130) pour calibrer les seuils réels :

| Zone | Lignes frame | ly local | Observation pixel |
|---|---|---|---|
| Tête | 13–31 | `ly < 0` | Largeur ≤ 22 px |
| Torse | 32–41 | `0 ≤ ly < +10` | Saut à 26–30 px : épaules |
| Mains | 42–51 | `+10 ≤ ly < +20` | Avant-bras + mains |
| Jambes | 52–57 | `+20 ≤ ly < +26` | Largeur chute à 12–14 px |
| Pieds | 58–61 | `ly ≥ +26` | |

- Bras détectés dans la bande `0 à +20` si `|lx| > frame_w * 0.17` (~11 px hors torse central)
- La limite Tête / Torse démarre désormais exactement au niveau du haut des bras (épaules, `ly = 0`)

**Fichiers :** `Scenes/Player/player.gd`

---

## Sauvegarde des PNJ — robustesse multi-callsite

**Problème initial :** trois appelants de `liblevel.saveAllObjects()` (`player.gd`, `base_level.gd`, `main_menu.gd`) ne passaient pas la liste des PNJ, ce qui écrasait `npcs.json` avec un tableau vide.

**Améliorations apportées :**

- Signature de `saveAllObjects()` étendue avec le paramètre `npcs = []`
- Les trois callsites passent désormais `get_tree().get_nodes_in_group("npc")`
- `reinitializeLevel()` inclut `"npcs.json"` dans la liste des fichiers à supprimer
- Vérification null-safe sur `FileAccess.open()` avant écriture de `npcs.json`

**Fichiers :** `Lib/liblevel.gd`, `Scenes/Player/player.gd`, `Scenes/Levels/base_level.gd`, `UI/main_menu.gd`

---

## Chargement des PNJ — application de l'état mort

**Problème initial :** `apply_dead_state()` était appelé depuis `_load_npcs()` via `call_deferred`, avant que les nœuds `@onready` (`name_label`, `interaction_label`) ne soient disponibles.

**Amélioration apportée :**

- L'appel à `apply_dead_state()` est déplacé dans `npc.setup()`, qui est exécuté après `add_child()` — les `@onready` sont donc résolus
- `setup()` lit `config.get("dead", false)` et `config.get("death_rotation", PI/2)` et appelle `apply_dead_state()` directement

**Fichiers :** `Objects/NPC/npc.gd`, `Scenes/Levels/base_level.gd`

---

## Mode d'affichage — passage en mode fenêtré

**Contexte :** le projet était configuré en plein écran sans bordures (`window/size/mode=3`) ce qui gênait le développement.

**Amélioration apportée :**

- `window/size/mode=0` (fenêtré) dans `project.godot`
- Viewport 1280×720 conservé
- `window/stretch/mode="canvas_items"` + `window/stretch/scale_mode="integer"` : pas de flou, mise à l'échelle entière

**Fichiers :** `project.godot`

---

## Option de debug — visibilité de la ligne de tir

**Contexte :** la ligne rouge entre le joueur et la cible pouvait gêner en cas de test.

**Amélioration apportée :**

- Case à cocher **"Afficher la ligne rouge de la cible"** dans **Settings → Debug**
- Contrôlée par `GameConfig.show_aim_line` (autoload), persistée dans `user://settings.json`
- Appliquée en temps réel dans `_CrosshairDraw._draw()` : `if line_visible and GameConfig.show_aim_line:`

**Fichiers :** `Autoload/game_config.gd`, `UI/main_menu.tscn`, `UI/main_menu.gd`, `Scenes/Player/player.gd`

---

## Page Vidéo — connexions signal branchées programmatiquement

**Problème initial :** les connexions ajoutées manuellement dans le `.tscn` pour les boutons Vidéo/Appliquer/Retour n'étaient pas prises en compte par Godot (scène potentiellement mise en cache avec l'ancien état du nœud `Video` qui était un `Label`).

**Amélioration apportée :**

- Suppression des 3 connexions du `.tscn`
- Branchement dans `_connect_video_settings()` appelé depuis `_ready()` avec `is_connected()` pour éviter les doublons — même pattern que les éléments UI créés dynamiquement

**Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`

---

## Page Vidéo — gestion de la limitation mode éditeur

**Problème initial :** `DisplayServer.window_set_mode(WINDOW_MODE_FULLSCREEN)` est refusé dans la fenêtre embarquée de l'éditeur Godot (`Embedded window only supports Windowed mode`) — le bouton "Appliquer" semblait sans effet.

**Amélioration apportée :**

- Détection via `OS.has_feature("editor")` : en mode éditeur, le changement de mode est sauté mais la préférence est quand même écrite dans `user://settings.json`
- `LabelHint` (orange) affiché sur le panel Vidéo en mode éditeur : *"Plein écran non disponible dans l'éditeur. Le réglage sera appliqué au lancement du jeu."*
- En build standalone, le bouton "Appliquer" fonctionne normalement

**Fichiers :** `UI/main_menu.tscn`, `UI/main_menu.gd`

---

## Armurerie — affichage image à hauteur fixe (TextureRect)

**Problème initial :** la zone d'affichage de la photo d'arme ne respectait pas la hauteur de 180 px définie par `custom_minimum_size`.

**Cause :**

- Premier essai (`expand_mode = 1` + `stretch_mode = 6`) : `EXPAND_IGNORE_SIZE` avec `STRETCH_KEEP_ASPECT_COVERED` affichait l'image à sa taille naturelle ou la recadrait sans respecter les contraintes de layout.
- Deuxième essai (`expand_mode = 0` + `stretch_mode = 5`) : `EXPAND_KEEP_SIZE` force la taille minimale du nœud à égaler la taille de la texture — une image 800×600 écrasait le `custom_minimum_size = (0, 180)`.

**Solution retenue :**

- `expand_mode = 1` (IGNORE_SIZE) : la taille de la texture n'influence pas le layout du nœud
- `stretch_mode = 5` (KEEP_ASPECT_CENTERED) : l'image est mise à l'échelle pour tenir dans les bornes du nœud en conservant son ratio, centrée
- `size_flags_vertical = 0` (SHRINK_BEGIN) : le nœud ne s'étire pas au-delà de son `custom_minimum_size`
- `custom_minimum_size = Vector2(0, 180)` : hauteur garantie à 180 px

**Fichiers :** `UI/armory.tscn`

---

## Vision nocturne — shader : `return` interdit dans `fragment()`

**Problème initial :** le shader utilisait `return` pour court-circuiter le traitement des pixels hors-cône, ce qui provoquait une erreur de compilation Godot (`Using 'return' in the 'fragment' processor function is incorrect`).

**Amélioration apportée :**

- `return` remplacé par un `if/else` équivalent : les pixels hors-cône reçoivent directement la couleur originale de l'écran (`COLOR = s`), les pixels dans le cône reçoivent le filtre NVG

**Fichiers :** `Shaders/night_vision.gdshader`

---

## HUD — largeur du ClockPanel HBox fixée à 200 px

**Contexte :** la largeur du `HBoxContainer` du panneau horloge variait selon le contenu, ce qui pouvait provoquer des décalages visuels.

**Amélioration apportée :**

- `custom_minimum_size = Vector2(200, 0)` ajouté sur le nœud `HBox` de `ClockAnchor/ClockPanel`

**Fichiers :** `UI/hud.tscn`

---

## Système multi-personnages — persistance et restauration des positions

**Problèmes initiaux (plusieurs bugs cumulés) :**

1. `save_party()` n'enregistrait que les slugs — aucune position ni stat des membres non-actifs
2. `save_full_party()` ne lisait pas les nœuds inactifs → leurs positions n'étaient jamais mises à jour avant l'écriture sur disque
3. `load_party()` n'était jamais appelé au démarrage → `PartyData.slots` vide à chaque lancement
4. `_on_cs_play_pressed()` appelait `setup_solo()` inconditionnellement, écrasant l'équipe sauvegardée
5. `_load_slot_data_for_party()` remplaçait le dict `data` de chaque membre sans préserver `pos_x/pos_y`
6. `PartyData.slots[0]["data"] = snapshot_player_data()` dans les deux chemins "Jouer" écrasait la position du chef sans la conserver
7. `active_slot` n'était jamais remis à 0 au clic "Jouer" → si le joueur avait basculé sur le perso 2 en fin de session, le chef redevenait inactif au rechargement
8. `_spawn_party()` utilisait toujours `rpg.json` pour le slot actif, ignorant la position (plus récente) de `party.json`

**Améliorations apportées :**

- `save_party()` : enregistre le dict `data` complet (`pos_x`, `pos_y`, toutes les stats) pour chaque slot
- `save_full_party()` : snapshot du slot actif depuis `Player_data` + `player_pos_x/y` ; slots inactifs mis à jour depuis `PartyData.get_node_at(i).global_position`
- `load_party()` : restaure le dict `data` depuis le JSON ; appelé dans `main_menu._ready()` si `slot_count() == 0`
- `_on_cs_play_pressed()` : ne réinitialise en solo que si le slug diffère du chef actuel ; appelle `_load_slot_data_for_party()` dans le cas contraire
- `_update_slot0_preserving_pos()` : nouvelle fonction — lit `pos_x/pos_y` existants avant de remplacer le dict du chef
- `PartyData.active_slot = 0` ajouté dans les deux chemins "Jouer" (character select et character manager)
- `_load_slot_data_for_party()` : préserve `saved_pos_x/y` des slots avant de les remplacer par le snapshot frais de `rpg.json`
- `_spawn_party()` : utilise `party.json` (`d["pos_x/y"]`) pour le slot actif si disponible et hors transition JSON ; repli sur `_place_player()` sinon

**Fichiers :** `Scenes/Player/party_data.gd`, `Scenes/Levels/base_level.gd`, `UI/main_menu.gd`

---

## Idées d'amélioration — Jeu en équipe

Pistes d'évolution futures pour le système multi-personnages. Aucune n'est encore implémentée.

---

### 1. Mini-portraits de l'équipe dans le HUD

Afficher une barre horizontale compacte en bas ou en haut de l'écran, avec un mini-portrait par membre :
- Indicateur de santé sous chaque portrait (barre ou fraction)
- Surbrillance du portrait du personnage actif
- Clic sur un portrait = switch vers ce personnage (équivalent Shift+N)
- Grisé + icône ☠ si le membre est mort

**Fichiers concernés :** `UI/hud.tscn`, `UI/hud.gd`, `Scenes/Player/player.gd`

---

### 2. Indicateur hors-écran des membres inactifs

Quand un membre de l'équipe se trouve hors des limites de l'écran, afficher une petite flèche colorée (couleur du slot) sur le bord de l'écran pointant vers sa position — comme un radar de bord. Utile après un switch si les personnages étaient loin les uns des autres.

**Implémentation suggérée :** `CanvasLayer` sur la caméra active ; calcul de direction `world_to_screen()` → si hors viewport, projeter sur le bord et placer une `Polygon2D` triangle.

**Fichiers concernés :** `Scenes/Player/player.gd` (actif) ou nouveau `UI/party_compass.gd`

---

### 3. Mode suivi automatique pour les membres inactifs

Ajouter un toggle (raccourci ou menu radial) pour que les membres inactifs suivent automatiquement le personnage actif à distance fixe (formation). En mode suivi :
- Chaque inactif se déplace vers la position du chef avec un `NavigationAgent2D` ou un lerp simple
- Ils conservent leur propre `CollisionShape2D` pour ne pas traverser les murs
- Un offset par slot évite qu'ils se superposent (ex. : −40 px à gauche, +40 px à droite)

**Fichiers concernés :** `Scenes/Player/player.gd` (inactif, `_physics_process`), `EventBus.gd` (signal position chef), `Autoload/player_data.gd` (flag `party_follow_mode`)

---

### 4. Partage de ressources entre membres

Option pour que les crédits et l'inventaire soient partagés entre tous les membres de l'équipe plutôt qu'individuels :
- `PartyData` exposerait `shared_credits` et `shared_inventory`
- Achats à l'armurerie débitent le pool commun
- Collectes incrémentent le pool commun
- Activable/désactivable depuis le gestionnaire de personnages

**Fichiers concernés :** `Scenes/Player/party_data.gd`, `UI/armory.gd`, `Scenes/Player/player.gd`

---

### 5. Cooldown et animation de switch

Empêcher le spam de Shift+1/2/3/4 en ajoutant un délai entre deux switchs (ex. : 0,5 s) avec un indicateur visuel sur les portraits HUD (barre de recharge). Optionnellement, une animation de fondu (flash blanc rapide) au moment du switch pour signaler visuellement le changement.

**Implémentation suggérée :** timer `_switch_cooldown` dans `base_level.gd` ou `player.gd` ; signal `party_switch_blocked` pour animer le HUD.

**Fichiers concernés :** `Scenes/Levels/base_level.gd`, `UI/hud.gd`

---

### 6. Assistance au combat par les membres inactifs

Quand le personnage actif engage un combat, les membres inactifs à portée participent passivement :
- Bonus de dés (ex. : +2 à l'attaque ou la défense) selon les stats de chaque allié présent
- Message dans le `CombatUI` : *"[Nom] vous couvre — Défense +2"*
- Portée configurable (ex. : 80 px)

**Fichiers concernés :** `Scenes/Player/player.gd` (`_start_combat()`), `UI/combat_ui.gd`, `Scenes/Player/party_data.gd`

---

### 7. Transfert d'équipement entre membres

Interface dans le gestionnaire de personnages (ou pendant une pause in-game) pour déplacer des objets de l'inventaire d'un membre vers un autre :
- Liste déroulante "De : [membre A]" / "Vers : [membre B]"
- Chaque objet affiché avec bouton "Transférer"
- Mis à jour dans `PartyData.slots[i]["data"]["player_equipment"]`

**Fichiers concernés :** `UI/main_menu.gd`, `Scenes/Player/party_data.gd`

---

### 8. Statut de mission partagé dans le récapitulatif

Sur l'écran de récapitulatif de mission, afficher une ligne par membre de l'équipe avec sa contribution (ex. : ordinateurs collectés, ennemis vaincus, distance parcourue) pour donner un sens au jeu en équipe.

**Implémentation suggérée :** tracker par slot dans `PartyData` (`kills`, `objects_collected`, `distance`) ; section "Équipe" dans `_show_mission_recap()`.

**Fichiers concernés :** `Scenes/Player/party_data.gd`, `UI/main_menu.gd`

---

### 9. Santé individuelle et soins entre membres

Actuellement tous les membres partagent `Player_data.player_health`. Gérer une santé distincte par slot :
- `PartyData.slots[i]["data"]["player_health"]` persiste la santé de chaque membre
- Un membre à 0 PV devient indisponible (portrait grisé, impossible à sélectionner)
- Action "Soigner" (touche ou menu radial) à portée d'un allié : transfère des PV du chef vers le blessé

**Fichiers concernés :** `Scenes/Player/party_data.gd`, `Scenes/Levels/base_level.gd`, `Scenes/Player/player.gd`

---

## Création de personnage — variable `name` renommée en `entry`

**Problème initial :** warning GDScript `SHADOWED_VARIABLE_BASE_CLASS` sur `main_menu.gd:1276` — la variable locale `name` dans `_delete_dir_recursive()` masquait la propriété `Node.name`.

**Amélioration apportée :**

- Variable locale renommée `entry` dans la boucle `DirAccess` de `_delete_dir_recursive()`

**Fichiers :** `UI/main_menu.gd`

● 9 idées ajoutées dans improvement.md, toutes ancrées dans l'architecture actuelle avec les fichiers concernés et des
  pistes d'implémentation concrètes :

  ┌─────┬────────────────────────────────────────────────────────────────────┬────────────┐
  │  #  │                                Idée                                │ Complexité │
  ├─────┼────────────────────────────────────────────────────────────────────┼────────────┤
  │ 1   │ Mini-portraits HUD avec santé de chaque membre + clic pour switch  │ Moyenne    │
  ├─────┼────────────────────────────────────────────────────────────────────┼────────────┤
  │ 2   │ Flèche hors-écran pointant vers les membres inactifs               │ Moyenne    │
  ├─────┼────────────────────────────────────────────────────────────────────┼────────────┤
  │ 3   │ Mode suivi automatique — les inactifs suivent le chef en formation │ Élevée     │
  ├─────┼────────────────────────────────────────────────────────────────────┼────────────┤
  │ 4   │ Crédits et inventaire partagés entre tous les membres              │ Faible     │
  ├─────┼────────────────────────────────────────────────────────────────────┼────────────┤
  │ 5   │ Cooldown de switch avec animation de transition                    │ Faible     │
  ├─────┼────────────────────────────────────────────────────────────────────┼────────────┤
  │ 6   │ Assistance passive au combat — bonus de dés si alliés à portée     │ Faible     │
  ├─────┼────────────────────────────────────────────────────────────────────┼────────────┤
  │ 7   │ Transfert d'équipement entre membres depuis le menu                │ Moyenne    │
  ├─────┼────────────────────────────────────────────────────────────────────┼────────────┤
  │ 8   │ Statistiques par membre dans le récapitulatif de mission           │ Moyenne    │
  ├─────┼────────────────────────────────────────────────────────────────────┼────────────┤
  │ 9   │ Santé individuelle par slot + soins entre membres                  │ Élevée     │
  └─────┴────────────────────────────────────────────────────────────────────┴────────────┘

