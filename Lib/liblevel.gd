extends RefCounted

static var version = "1"

func _mission_state_path() -> String:
	if Player_data.character_slug != "":
		return "user://characters/%s/mission_state.json" % Player_data.character_slug
	return "user://current_mission.json"

func displayVersion():
	return "LibLevel version: " + version

# ~/.local/share/godot/app_userdata/rpg_v1/player.json
func savePlayer(data_to_save):
	if GameConfig.DEBUG:
		print("SavePlayer")
	var to_json = JSON.stringify(data_to_save)
	var file = FileAccess.open(Player_data.save_path, FileAccess.WRITE)
	file.store_line(to_json)
	file.close()
	
func saveAllObjects(current_scene, computers, robots, robot_enemies = [], mechas = [], npcs = []):
	if GameConfig.DEBUG:
		print("saveAllObjects")

	var base_dir := Player_data.level_save_dir(current_scene)
	DirAccess.make_dir_recursive_absolute(base_dir)

	# objects.json — computers + robots collectibles
	var objects_data: Array = []
	for computer in computers:
		var col_data: Dictionary = computer.get_collision_data()
		objects_data.append({
			"type": "computer", "x": computer.position.x, "y": computer.position.y,
			"collision_radius":    col_data["collision_radius"],
			"collision_offset_x":  col_data["collision_offset_x"],
			"collision_offset_y":  col_data["collision_offset_y"],
		})
	for robot in robots:
		var col_data: Dictionary = robot.get_collision_data()
		objects_data.append({
			"type": "robot", "x": robot.position.x, "y": robot.position.y,
			"collision_radius":    col_data["collision_radius"],
			"collision_offset_x":  col_data["collision_offset_x"],
			"collision_offset_y":  col_data["collision_offset_y"],
		})
	var objects_file = FileAccess.open(base_dir + "/objects.json", FileAccess.WRITE)
	objects_file.store_line(JSON.stringify(objects_data))
	objects_file.close()

	# enemies.json — robot enemies
	var enemies_data: Array = []
	for enemy in robot_enemies:
		var col_data: Dictionary = enemy.get_collision_data()
		enemies_data.append({
			"x": enemy.position.x,
			"y": enemy.position.y,
			"attack":            enemy.enemy_attack,
			"defense":           enemy.enemy_defense,
			"health":            enemy.enemy_health,
			"follow_player":     1 if enemy.follow_player else 0,
			"facing_angle":      enemy.facing_angle,
			"dead":              enemy.is_dead,
			"death_rotation":    enemy.death_rotation,
			"collision_width":   col_data["collision_width"],
			"collision_height":  col_data["collision_height"],
			"collision_offset_x": col_data["collision_offset_x"],
			"collision_offset_y": col_data["collision_offset_y"],
		})
	var enemies_file = FileAccess.open(base_dir + "/enemies.json", FileAccess.WRITE)
	enemies_file.store_line(JSON.stringify(enemies_data))
	enemies_file.close()

	# mechas.json — positions des mechas
	var mechas_data: Array = []
	for mecha in mechas:
		if mecha.has_method("get_save_data"):
			mechas_data.append(mecha.get_save_data())
	var mechas_file = FileAccess.open(base_dir + "/mechas.json", FileAccess.WRITE)
	mechas_file.store_line(JSON.stringify(mechas_data))
	mechas_file.close()

	# npcs.json — état vivant/mort des PNJ
	var npcs_data: Array = []
	for npc in npcs:
		var npc_col: Dictionary = npc.get_collision_data()
		npcs_data.append({
			"x":               npc.position.x,
			"y":               npc.position.y,
			"id":              npc.npc_id,
			"name":            npc.npc_name,
			"dialogue":        npc.dialogue,
			"dead":            npc.is_dead,
			"death_rotation":  npc.death_rotation,
			"collision_width":    npc_col["collision_width"],
			"collision_height":   npc_col["collision_height"],
			"collision_offset_x": npc_col["collision_offset_x"],
			"collision_offset_y": npc_col["collision_offset_y"],
		})
	var npcs_file = FileAccess.open(base_dir + "/npcs.json", FileAccess.WRITE)
	if npcs_file != null:
		npcs_file.store_line(JSON.stringify(npcs_data))
		npcs_file.close()
	
func save_mission_state(mission_id: String, started: bool, elapsed_real: float = 0.0, started_at: String = "", game_datetime: String = "") -> void:
	var prev := load_mission_state()
	if started_at == "":
		started_at = prev.get("started_at", "")
	if game_datetime == "":
		game_datetime = prev.get("game_datetime", "")
	var now := Time.get_datetime_dict_from_system()
	var saved_at := "%04d-%02d-%02d %02d:%02d:%02d" % [now.year, now.month, now.day, now.hour, now.minute, now.second]
	var data := {
		"mission_id": mission_id,
		"started": started,
		"mission_elapsed_real": elapsed_real,
		"started_at": started_at,
		"saved_at": saved_at,
		"game_datetime": game_datetime
	}
	var file := FileAccess.open(_mission_state_path(), FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(data))
		file.close()

func load_mission_state() -> Dictionary:
	var file := FileAccess.open(_mission_state_path(), FileAccess.READ)
	if file == null:
		return {}
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data is Dictionary:
		return data
	return {}

func reinitializeLevel():
	if GameConfig.DEBUG:
		print("Reinitialize Level")
	var mission_path := _mission_state_path()
	if FileAccess.file_exists(mission_path):
		DirAccess.remove_absolute(mission_path)
	var party_path := PartyData.SAVE_PATH
	if FileAccess.file_exists(party_path):
		DirAccess.remove_absolute(party_path)
	PartyData.slots.clear()
	PartyData.active_slot = 0
	for level in ["level_1", "level_2", "level_3", "level_4", "level_5", "level_6", "level_7", "level_8", "level_9", "level_10"]:
		for file_name in ["objects.json", "enemies.json", "mechas.json", "npcs.json"]:
			var path := "%s/%s/%s" % [Player_data.character_dir(), level, file_name]
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(path)

func reinitializePlayer():
	if GameConfig.DEBUG:
		print("Reinitialize Player")
	if Player_data.character_slug == "":
		return
	DirAccess.make_dir_recursive_absolute(Player_data.character_dir())
	var src := FileAccess.open("res://World/Default/player.json", FileAccess.READ)
	if src == null:
		push_error("reinitializePlayer: fichier source introuvable: res://World/Default/player.json")
		return
	var content := src.get_as_text()
	src.close()
	var dst := FileAccess.open(Player_data.save_path, FileAccess.WRITE)
	if dst == null:
		push_error("reinitializePlayer: impossible d'écrire: " + Player_data.save_path)
		return
	dst.store_string(content)
	dst.close()


func _load_default_player_json() -> Dictionary:
	var src := FileAccess.open("res://World/Default/player.json", FileAccess.READ)
	if src == null:
		return {}
	var data = JSON.parse_string(src.get_as_text())
	src.close()
	return data if data is Dictionary else {}


func load_game():
	# ~/.local/share/godot/app_userdata/rpg_v1/player.json
	var defaults: Dictionary = _load_default_player_json()
	if FileAccess.file_exists(Player_data.save_path):
		if GameConfig.DEBUG:
			print("Character file found")
		var file = FileAccess.open(Player_data.save_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		# Load the saved scene
		var saved_scene = data.get("scene", "")
		if saved_scene == "":
			saved_scene = Player_data_default.scene_start
		Player_data.scene_path = "res://Scenes/Levels/%s/%s.tscn" % [saved_scene, saved_scene]
		Player_data.player_spawnpoint_position_x = data["player_position"][0]
		Player_data.player_spawnpoint_position_y = data["player_position"][1]
		Player_data.player_facing = data.get("player_facing", 8)
		Player_data.player_body_angle = float(data.get("body_angle", -90.0))
		Player_data.player_health = data.get("player_health", Player_data.player_health)
		Player_data.player_health_base = data.get("player_health_base", Player_data.player_health)
		Player_data.player_movement      = data.get("player_movement", 50)
		Player_data.player_movement_base = data.get("player_movement_base", 50)
		Player_data.player_attack          = data.get("player_attack", 0)
		Player_data.player_defense         = data.get("player_defense", 0)
		Player_data.player_stamina         = data.get("player_stamina", 0)
		Player_data.player_stealth         = data.get("player_stealth", 0)
		Player_data.player_speed           = data.get("player_speed", 0)
		Player_data.player_precision       = data.get("player_precision", 0)
		Player_data.player_strength        = data.get("player_strength", 0)
		Player_data.player_intelligence    = data.get("player_intelligence", 0)
		Player_data.player_weight_capacity = data.get("player_weight_capacity", 0)
		Player_data.player_credit          = data.get("player_credit", 1000)
		Player_data.player_equipment       = data.get("player_equipment", [])
		Player_data.player_nickname = data.get("player_nickname", "")
		Player_data.player_biography = data.get("player_biography", "")
		Player_data.player_rank = data.get("player_rank", "")
		Player_data.player_specialization = data.get("player_specialization", "")
		Player_data.appearance_body     = data.get("appearance_body", "body_light")
		Player_data.appearance_hair     = data.get("appearance_hair", "")
		Player_data.appearance_headwear = data.get("appearance_headwear", "")
		Player_data.appearance_arms     = data.get("appearance_arms", "")
		Player_data.appearance_hands    = data.get("appearance_hands", "")
		Player_data.appearance_torso    = data.get("appearance_torso", "")
		Player_data.appearance_legs     = data.get("appearance_legs", "")
		Player_data.appearance_feet     = data.get("appearance_feet", "")
		Player_data.player_collision_width    = float(data.get("collision_width",    defaults.get("collision_width",    32.0)))
		Player_data.player_collision_height   = float(data.get("collision_height",   defaults.get("collision_height",   50.0)))
		Player_data.player_collision_offset_x = float(data.get("collision_offset_x", defaults.get("collision_offset_x",  0.0)))
		Player_data.player_collision_offset_y = float(data.get("collision_offset_y", defaults.get("collision_offset_y",  5.0)))

	else:
		if GameConfig.DEBUG:
			print("Save file not found!")
		Player_data.scene_path = "res://Scenes/Levels/%s/%s.tscn" % [Player_data_default.scene_start, Player_data_default.scene_start]
		Player_data.player_spawnpoint_position_x = Player_data_default.spawnpoint_position_x
		Player_data.player_spawnpoint_position_y = Player_data_default.spawnpoint_position_y
		Player_data.player_movement      = 50
		Player_data.player_movement_base = 50
		Player_data.player_attack          = 0
		Player_data.player_defense         = 0
		Player_data.player_stamina         = 0
		Player_data.player_stealth         = 0
		Player_data.player_speed           = 0
		Player_data.player_precision       = 0
		Player_data.player_strength        = 0
		Player_data.player_intelligence    = 0
		Player_data.player_weight_capacity = 0
		Player_data.player_credit          = 1000
		Player_data.player_equipment       = []
		Player_data.player_body_angle         = -90.0
		Player_data.player_collision_width    = float(defaults.get("collision_width",    32.0))
		Player_data.player_collision_height   = float(defaults.get("collision_height",   50.0))
		Player_data.player_collision_offset_x = float(defaults.get("collision_offset_x",  0.0))
		Player_data.player_collision_offset_y = float(defaults.get("collision_offset_y",  5.0))
