extends RefCounted

static var version = "1"

const MISSION_STATE_PATH = "user://current_mission.json"

func displayVersion():
	return "LibLevel version: " + version

# ~/.local/share/godot/app_userdata/rpg_v1/rpg.json
func savePlayer(data_to_save):
	if GameConfig.DEBUG:
		print("SavePlayer")
	var to_json = JSON.stringify(data_to_save)
	var file = FileAccess.open(Player_data.save_path, FileAccess.WRITE)
	file.store_line(to_json)
	file.close()
	
func saveAllObjects(current_scene, computers, robots, robot_enemies = [], mechas = []):
	if GameConfig.DEBUG:
		print("saveAllObjects")

	DirAccess.make_dir_absolute("user://" + current_scene)

	# objects.json — computers + robots collectibles
	var objects_data: Array = []
	for computer in computers:
		objects_data.append({ "type": "computer", "x": computer.position.x, "y": computer.position.y })
	for robot in robots:
		objects_data.append({ "type": "robot", "x": robot.position.x, "y": robot.position.y })
	var objects_file = FileAccess.open("user://%s/objects.json" % current_scene, FileAccess.WRITE)
	objects_file.store_line(JSON.stringify(objects_data))
	objects_file.close()

	# enemies.json — robot enemies
	var enemies_data: Array = []
	for enemy in robot_enemies:
		enemies_data.append({
			"x": enemy.position.x,
			"y": enemy.position.y,
			"attack":         enemy.enemy_attack,
			"defense":        enemy.enemy_defense,
			"health":         enemy.enemy_health,
			"dead":           enemy.is_dead,
			"death_rotation": enemy.death_rotation
		})
	var enemies_file = FileAccess.open("user://%s/enemies.json" % current_scene, FileAccess.WRITE)
	enemies_file.store_line(JSON.stringify(enemies_data))
	enemies_file.close()

	# mechas.json — positions des mechas
	var mechas_data: Array = []
	for mecha in mechas:
		if mecha.has_method("get_save_data"):
			mechas_data.append(mecha.get_save_data())
	var mechas_file = FileAccess.open("user://%s/mechas.json" % current_scene, FileAccess.WRITE)
	mechas_file.store_line(JSON.stringify(mechas_data))
	mechas_file.close()
	
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
	var file := FileAccess.open(MISSION_STATE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(data))
		file.close()

func load_mission_state() -> Dictionary:
	var file := FileAccess.open(MISSION_STATE_PATH, FileAccess.READ)
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
	if FileAccess.file_exists(MISSION_STATE_PATH):
		DirAccess.remove_absolute(MISSION_STATE_PATH)
	for level in ["level_1", "level_2", "level_3", "level_4"]:
		for file_name in ["objects.json", "enemies.json", "mechas.json"]:
			var path = "user://%s/%s" % [level, file_name]
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(path)

func reinitializePlayer():
	if GameConfig.DEBUG:
		print("Reinitialize Player")
	#mDirAccess.remove_absolute(Player_data.save_path)
	
	var dir = DirAccess.open("res://World/Default/")
	dir.copy("res://World/Default/rpg.json", "user://rpg.json")


func load_game():
	# ~/.local/share/godot/app_userdata/rpg_v1/rpg.json
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
		Player_data.player_health = data.get("player_health", Player_data.player_health)
		Player_data.player_health_base = data.get("player_health_base", Player_data.player_health)
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

	else:
		if GameConfig.DEBUG:
			print("Save file not found!")
		Player_data.scene_path = "res://Scenes/Levels/%s/%s.tscn" % [Player_data_default.scene_start, Player_data_default.scene_start]
		Player_data.player_spawnpoint_position_x = Player_data_default.spawnpoint_position_x
		Player_data.player_spawnpoint_position_y = Player_data_default.spawnpoint_position_y
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
