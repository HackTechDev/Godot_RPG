extends Node2D

@onready var player_scene = preload("res://Scenes/Player/player.tscn")
var _indicator_script = preload("res://Scenes/Levels/spawnpoint_indicator.gd")
var _liblevel = preload("res://Lib/liblevel.gd").new()

# Empêche les zones JSON de se déclencher immédiatement après un spawn
var _transition_cooldown := false

const _CONNECTIONS_PATH = "res://Data/level_connections.json"


func _ready() -> void:
	if GameConfig.DEBUG:
		print("Scene: " + self.name)
	Player_data.player_previous_scene = self.name
	SceneTransition.fade_in()
	_add_spawnpoint_visuals()
	_setup_json_transitions()

	var player = player_scene.instantiate()
	_place_player(player)
	add_child(player)


# ---------------------------------------------------------------------------
# Placement du joueur — trois systèmes par ordre de priorité
# ---------------------------------------------------------------------------

func _place_player(player: Node2D) -> void:
	# Priorité 1 : système JSON (position absolue définie dans level_connections.json)
	if Player_data.use_json_spawn:
		player.position = Player_data.json_spawn
		Player_data.use_json_spawn = false
		return

	# Priorité 2 : système LevelDoor (porte nommée dans la scène destination)
	if Player_data.next_door != "":
		for door in get_tree().get_nodes_in_group("level_door"):
			if door.name == Player_data.next_door:
				player.global_position = door.global_position
				Player_data.next_door = ""
				return
		push_warning("base_level: LevelDoor '%s' introuvable." % Player_data.next_door)
		Player_data.next_door = ""

	# Priorité 3 : système historique (spawnpoints nommés + offset)
	if Player_data.spawnpoint_next == "":
		player.position.x = Player_data.player_spawnpoint_position_x
		player.position.y = Player_data.player_spawnpoint_position_y
	else:
		var node_name = "/root/%s/spawnpoint_%s_%s_begin" % [self.name, self.name, Player_data.spawnpoint_next]
		player.position = get_node(node_name).position + Vector2(
			Player_data.player_spawnpoint_position_x,
			Player_data.player_spawnpoint_position_y
		)


# ---------------------------------------------------------------------------
# Système JSON : lecture de level_connections.json + création des déclencheurs
# ---------------------------------------------------------------------------

func _setup_json_transitions() -> void:
	if not FileAccess.file_exists(_CONNECTIONS_PATH):
		return

	var file = FileAccess.open(_CONNECTIONS_PATH, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("base_level: level_connections.json invalide.")
		file.close()
		return
	file.close()

	# Cooldown si on vient d'arriver via une transition JSON
	if Player_data.use_json_spawn:
		_transition_cooldown = true
		get_tree().create_timer(0.5).timeout.connect(
			func() -> void: _transition_cooldown = false
		)

	var my_scene := "res://Scenes/Levels/%s/%s.tscn" % [name, name]
	for conn in json.data.get("connections", []):
		for side in ["a", "b"]:
			var me: Dictionary  = conn.get(side, {})
			var other: Dictionary = conn.get("b" if side == "a" else "a", {})
			if me.get("scene", "") == my_scene:
				_create_json_trigger(me, other)


func _create_json_trigger(me: Dictionary, other: Dictionary) -> void:
	var t:      Dictionary = me.get("trigger", {})
	var spawn:  Dictionary = other.get("spawn", {})
	var target: String     = other.get("scene", "")

	if target == "" or t.is_empty() or spawn.is_empty():
		push_warning("base_level: connexion JSON incomplète, ignorée.")
		return

	var area := Area2D.new()
	area.position      = Vector2(t.get("x", 0.0), t.get("y", 0.0))
	area.collision_layer = 2

	var col  := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(t.get("w", 64.0), t.get("h", 64.0))
	col.shape = rect
	area.add_child(col)

	var spawn_pos := Vector2(spawn.get("x", 0.0), spawn.get("y", 0.0))
	area.body_entered.connect(
		func(body: Node2D) -> void:
			_on_json_trigger_entered(body, target, spawn_pos)
	)
	add_child(area)


func _on_json_trigger_entered(body: Node2D, target_scene: String, spawn_pos: Vector2) -> void:
	if _transition_cooldown or not body.is_in_group("player"):
		return
	_save_transition_state(body)
	Player_data.use_json_spawn  = true
	Player_data.json_spawn      = spawn_pos
	Player_data.spawnpoint_next = ""
	Player_data.next_door       = ""
	SceneTransition.change_scene(target_scene)


# ---------------------------------------------------------------------------
# Sauvegarde complète lors d'une transition (JSON ou LevelDoor)
# ---------------------------------------------------------------------------

func _save_transition_state(player: Node2D) -> void:
	var computers     := get_tree().get_nodes_in_group("computer")
	var robots        := get_tree().get_nodes_in_group("robot")
	var robot_enemies := get_tree().get_nodes_in_group("robot_enemy")
	_liblevel.saveAllObjects(Player_data.player_previous_scene, computers, robots, robot_enemies)
	_liblevel.savePlayer({
		"player_position":    [player.position.x, player.position.y],
		"player_facing":      Player_data.player_facing,
		"scene":              Player_data.player_previous_scene,
		"player_health":      Player_data.player_health,
		"player_health_base": Player_data.player_health_base,
		"player_attack":      Player_data.player_attack,
		"player_defense":     Player_data.player_defense,
		"player_nickname":    Player_data.player_nickname,
		"player_biography":   Player_data.player_biography,
		"player_rank":        Player_data.player_rank,
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


# ---------------------------------------------------------------------------
# Visuel de debug des spawnpoints (système historique)
# ---------------------------------------------------------------------------

func _add_spawnpoint_visuals() -> void:
	for child in get_children():
		if child is Marker2D and child.name.begins_with("spawnpoint_"):
			var indicator := Node2D.new()
			indicator.set_script(_indicator_script)
			child.add_child(indicator)
