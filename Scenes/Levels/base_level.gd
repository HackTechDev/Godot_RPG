extends Node2D

@onready var player_scene = preload("res://Scenes/Player/player.tscn")
var _liblevel = preload("res://Lib/liblevel.gd").new()

var _computer_scene = preload("res://Objects/Computers/computer.tscn")
var _robot_scene    = preload("res://Objects/Robots/robot.tscn")
var _enemy_scene    = preload("res://Objects/RobotEnemy/robot_enemy.tscn")
var _npc_scene      = preload("res://Objects/NPC/npc.tscn")

# Empêche les zones JSON de se déclencher immédiatement après un spawn
var _transition_cooldown := false

# Tous les triggers du niveau (détection basée sur le sprite, sans body_entered)
var _all_triggers: Array[Dictionary] = []

# Marge en pixels : le bord du sprite doit être à ≤ MARGIN px du bord du trigger
const _TRIGGER_MARGIN := 1.0

# Label de debug affiché quand le bord du sprite touche le bord du trigger
var _trigger_hint: Label = null


func _ready() -> void:
	if GameConfig.DEBUG:
		print("Scene: " + self.name)
	Player_data.player_previous_scene = self.name
	SceneTransition.fade_in()
	_setup_json_transitions()
	_load_objects()
	_load_enemies()
	_load_npcs()

	var player = player_scene.instantiate()
	_place_player(player)
	add_child(player)

	_trigger_hint = Label.new()
	_trigger_hint.text = "Haut du sprite = haut du trigger — appuyez sur Espace"
	_trigger_hint.visible = false
	_trigger_hint.add_theme_font_size_override("font_size", 14)
	_trigger_hint.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	_trigger_hint.add_theme_constant_override("outline_size", 2)
	_trigger_hint.add_theme_color_override("font_outline_color", Color.BLACK)
	_trigger_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_trigger_hint.position = Vector2(-200, -40)
	var _cl := CanvasLayer.new()
	_cl.layer = 20
	_cl.add_child(_trigger_hint)
	add_child(_cl)


# ---------------------------------------------------------------------------
# Placement du joueur — trois systèmes par ordre de priorité
# ---------------------------------------------------------------------------

func _place_player(player: Node2D) -> void:
	# Priorité 1 : système JSON (position absolue définie dans level_connections.json)
	if Player_data.use_json_spawn:
		player.position = Player_data.json_spawn
		Player_data.use_json_spawn = false
		return

	# Priorité 2 : position sauvegardée
	player.position = Vector2(
		Player_data.player_spawnpoint_position_x,
		Player_data.player_spawnpoint_position_y
	)


# ---------------------------------------------------------------------------
# Système JSON : lecture de level_connections.json + création des déclencheurs
# ---------------------------------------------------------------------------

func _setup_json_transitions() -> void:
	var path := "res://Scenes/Levels/%s/level_connections.json" % name
	if not FileAccess.file_exists(path):
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("base_level: level_connections.json invalide dans " + name)
		file.close()
		return
	file.close()

	# Cooldown si on vient d'arriver via une transition JSON
	if Player_data.use_json_spawn:
		_transition_cooldown = true
		get_tree().create_timer(0.5).timeout.connect(
			func() -> void: _transition_cooldown = false
		)

	for conn in json.data.get("connections", []):
		_create_json_trigger(conn)


func _create_json_trigger(conn: Dictionary) -> void:
	var t:      Dictionary = conn.get("trigger", {})
	var to:     Dictionary = conn.get("to", {})
	var target: String     = to.get("scene", "")

	if target == "" or t.is_empty():
		push_warning("base_level: connexion JSON incomplète dans " + name + ", ignorée.")
		return

	var area := Area2D.new()
	area.position      = Vector2(t.get("x", 0.0), t.get("y", 0.0))
	area.collision_layer = 2

	var w: float = t.get("w", 64.0)
	var h: float = t.get("h", 64.0)

	var col  := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	col.shape = rect
	area.add_child(col)

	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2( w * 0.5, -h * 0.5),
		Vector2( w * 0.5,  h * 0.5),
		Vector2(-w * 0.5,  h * 0.5),
	])
	poly.color = Color(1.0, 0.6, 0.0, 0.35)
	poly.z_index = 10
	area.add_child(poly)

	var trigger_rect := Rect2(
		area.position - Vector2(w * 0.5, h * 0.5),
		Vector2(w, h)
	)
	# Stocke le trigger pour la détection sprite-bord dans _unhandled_input
	_all_triggers.append({"target": target, "rect": trigger_rect})
	add_child(area)


func _process(_delta: float) -> void:
	if _trigger_hint == null or _all_triggers.is_empty():
		return
	if not GameConfig.debug_show_collision:
		_trigger_hint.visible = false
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		_trigger_hint.visible = false
		return
	var master_sprite := player.get_node_or_null("Sprite2D") as Sprite2D
	if master_sprite == null:
		_trigger_hint.visible = false
		return
	var local_rect: Rect2 = master_sprite.get_rect()
	var sw := Rect2(player.global_position + local_rect.position, local_rect.size)

	var hint_text := ""
	for trig in _all_triggers:
		var tr: Rect2 = trig["rect"]
		if tr.size.x >= tr.size.y:
			var x_overlap := sw.end.x > tr.position.x and sw.position.x < tr.end.x
			if not x_overlap:
				continue
			if absf(sw.position.y - tr.position.y) <= _TRIGGER_MARGIN:
				hint_text = "Haut du sprite = haut du trigger — appuyez sur Espace"
				break
			if absf(sw.end.y - tr.end.y) <= _TRIGGER_MARGIN:
				hint_text = "Bas du sprite = bas du trigger — appuyez sur Espace"
				break
		else:
			var y_overlap := sw.end.y > tr.position.y and sw.position.y < tr.end.y
			if not y_overlap:
				continue
			if absf(sw.position.x - tr.position.x) <= _TRIGGER_MARGIN:
				hint_text = "Gauche du sprite = gauche du trigger — appuyez sur Espace"
				break
			if absf(sw.end.x - tr.end.x) <= _TRIGGER_MARGIN:
				hint_text = "Droite du sprite = droite du trigger — appuyez sur Espace"
				break

	if hint_text != "":
		_trigger_hint.text = hint_text
		_trigger_hint.visible = true
	else:
		_trigger_hint.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_space") or _transition_cooldown or _all_triggers.is_empty():
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	# Rect du sprite en coordonnées monde (graphisme, pas collision shape)
	var master_sprite := player.get_node_or_null("Sprite2D") as Sprite2D
	if master_sprite == null:
		return
	var local_rect: Rect2 = master_sprite.get_rect()
	var sw := Rect2(player.global_position + local_rect.position, local_rect.size)

	for trig in _all_triggers:
		var tr: Rect2    = trig["rect"]
		var target: String = trig["target"]
		var horizontal := tr.size.x >= tr.size.y

		var in_zone: bool
		if horizontal:
			var x_overlap := sw.end.x > tr.position.x and sw.position.x < tr.end.x
			if not x_overlap:
				continue
			var at_top    := absf(sw.position.y - tr.position.y) <= _TRIGGER_MARGIN
			var at_bottom := absf(sw.end.y      - tr.end.y)      <= _TRIGGER_MARGIN
			in_zone = at_top or at_bottom
		else:
			var y_overlap := sw.end.y > tr.position.y and sw.position.y < tr.end.y
			if not y_overlap:
				continue
			var at_left  := absf(sw.position.x - tr.position.x) <= _TRIGGER_MARGIN
			var at_right := absf(sw.end.x      - tr.end.x)      <= _TRIGGER_MARGIN
			in_zone = at_left or at_right

		if not in_zone:
			continue

		# Bord trouvé — déclencher la transition
		var offset := player.global_position - tr.get_center()
		_save_transition_state(player)
		Player_data.use_json_spawn = true
		Player_data.json_spawn     = _compute_arrival_spawn(target, offset, horizontal)
		SceneTransition.change_scene(target)
		return


# Trouve le trigger de destination qui pointe vers cette scène et y applique l'offset inversé.
# Pour un trigger horizontal : entrée par le haut → arrivée en bas, et vice-versa.
# Pour un trigger vertical   : entrée par la droite → arrivée à gauche, et vice-versa.
func _compute_arrival_spawn(target_scene: String, offset: Vector2, src_horizontal: bool) -> Vector2:
	var dest_name := target_scene.get_basename().split("/")[-1]
	var dest_json := "res://Scenes/Levels/%s/level_connections.json" % dest_name

	if FileAccess.file_exists(dest_json):
		var file := FileAccess.open(dest_json, FileAccess.READ)
		var data: Variant = JSON.parse_string(file.get_as_text())
		file.close()
		if data is Dictionary:
			var my_scene := "res://Scenes/Levels/%s/%s.tscn" % [name, name]
			for conn in data.get("connections", []):
				var to: Dictionary = conn.get("to", {})
				if to.get("scene", "") == my_scene:
					var t: Dictionary = conn.get("trigger", {})
					var center := Vector2(t.get("x", 0.0), t.get("y", 0.0))
					# Inversion de l'axe perpendiculaire à la direction de passage
					var arrival_offset: Vector2
					if src_horizontal:
						arrival_offset = Vector2(offset.x, -offset.y)
					else:
						arrival_offset = Vector2(-offset.x, offset.y)
					return center + arrival_offset

	# Aucun trigger correspondant trouvé — fallback : offset seul
	push_warning("base_level: aucun trigger retour vers %s dans %s" % [name, dest_name])
	return offset


# ---------------------------------------------------------------------------
# Sauvegarde complète lors d'une transition (JSON ou LevelDoor)
# ---------------------------------------------------------------------------

func _save_transition_state(player: Node2D) -> void:
	var sprite := player.get_node_or_null("Sprite2D")
	if sprite:
		Player_data.player_sprite_frame = sprite.frame

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
# Chargement des objets, ennemis et NPC depuis les fichiers JSON du level
# ---------------------------------------------------------------------------

func _load_objects() -> void:
	var entries := _read_level_json(
		"user://%s/objects.json" % name,
		"res://Scenes/Levels/%s/objects.json" % name
	)
	for entry in entries:
		var obj: Node2D
		match entry.get("type", ""):
			"computer":
				obj = _computer_scene.instantiate()
				obj.add_to_group("computer")
			"robot":
				obj = _robot_scene.instantiate()
				obj.add_to_group("robot")
			_:
				continue
		obj.position = Vector2(entry.get("x", 0.0), entry.get("y", 0.0))
		add_child(obj)


func _load_enemies() -> void:
	var entries := _read_level_json(
		"user://%s/enemies.json" % name,
		"res://Scenes/Levels/%s/enemies.json" % name
	)
	for entry in entries:
		var enemy = _enemy_scene.instantiate()
		enemy.add_to_group("robot_enemy")
		enemy.position = Vector2(entry.get("x", 0.0), entry.get("y", 0.0))
		add_child(enemy)
		if entry.has("attack"):
			enemy.enemy_attack  = int(entry.get("attack",  10))
			enemy.enemy_defense = int(entry.get("defense", 10))
			enemy.enemy_health  = int(entry.get("health",   2))
		if entry.get("dead", false):
			enemy.death_rotation = float(entry.get("death_rotation", PI / 2.0))
			enemy.apply_dead_state()


func _load_npcs() -> void:
	var entries := _read_level_json(
		"",
		"res://Scenes/Levels/%s/npcs.json" % name
	)
	for entry in entries:
		var npc = _npc_scene.instantiate()
		npc.position = Vector2(entry.get("x", 0.0), entry.get("y", 0.0))
		add_child(npc)
		npc.setup(entry)


func _read_level_json(user_path: String, config_path: String) -> Array:
	for path in ([user_path] if user_path != "" else []) + [config_path]:
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			var data = JSON.parse_string(file.get_as_text())
			file.close()
			if data is Array:
				return data
	return []
