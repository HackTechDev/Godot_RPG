extends Area2D
## LevelDoor — porte de transition entre deux scènes.
##
## Usage :
##   1. Ajouter un nœud Area2D dans la scène, lui assigner ce script.
##   2. Ajouter un CollisionShape2D enfant (rectangle conseillé).
##   3. Dans l'inspecteur :
##        target_scene → sélectionner la scène de destination
##        target_door  → entrer le nom exact du LevelDoor dans cette scène
##   4. Répéter côté destination avec les valeurs inverses.
##
## Le joueur apparaît à la position de la porte destination.
## La porte destination se désactive 1 seconde pour éviter tout retour immédiat.

var _liblevel = preload("res://Lib/liblevel.gd").new()

## Scène à charger lors du passage.
@export_file("*.tscn") var target_scene: String = ""
## Nom du LevelDoor dans la scène cible (point de spawn du joueur).
@export var target_door: String = ""


func _ready() -> void:
	add_to_group("level_door")

	# Si cette porte est la destination d'une transition en cours,
	# désactiver la détection le temps que le joueur s'éloigne.
	if Player_data.next_door == name:
		monitoring = false
		get_tree().create_timer(1.0).timeout.connect(_re_enable_monitoring)


func _re_enable_monitoring() -> void:
	monitoring = true


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if target_scene == "" or target_door == "":
		push_warning("LevelDoor '%s' : target_scene ou target_door non configuré." % name)
		return

	_save_state(body)
	Player_data.next_door = target_door
	Player_data.spawnpoint_next = ""        # désactiver l'ancien système
	SceneTransition.change_scene(target_scene)


func _save_state(player: Node2D) -> void:
	var computers    = get_tree().get_nodes_in_group("computer")
	var robots       = get_tree().get_nodes_in_group("robot")
	var robot_enemies = get_tree().get_nodes_in_group("robot_enemy")
	_liblevel.saveAllObjects(
		Player_data.player_previous_scene,
		computers, robots, robot_enemies
	)
	_liblevel.savePlayer({
		"player_position": [player.position.x, player.position.y],
		"player_facing":   Player_data.player_facing,
		"scene":           Player_data.player_previous_scene,
		"player_health":   Player_data.player_health,
		"player_health_base": Player_data.player_health_base,
		"player_attack":   Player_data.player_attack,
		"player_defense":  Player_data.player_defense,
		"player_nickname": Player_data.player_nickname,
		"player_biography": Player_data.player_biography,
		"player_rank":     Player_data.player_rank,
		"player_specialization": Player_data.player_specialization,
		"appearance_body":     Player_data.appearance_body,
		"appearance_hair":     Player_data.appearance_hair,
		"appearance_headwear": Player_data.appearance_headwear,
		"appearance_arms":     Player_data.appearance_arms,
		"appearance_hands":    Player_data.appearance_hands,
		"appearance_torso":    Player_data.appearance_torso,
		"appearance_legs":     Player_data.appearance_legs,
		"appearance_feet":     Player_data.appearance_feet,
	})
