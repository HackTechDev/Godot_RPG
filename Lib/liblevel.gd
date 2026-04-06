extends RefCounted

static var version = "1"

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
	
func saveAllObjects(current_scene, computers, robots, robot_enemies = []):
	if GameConfig.DEBUG:
		print("saveAllObjects")
	var all_json_data = {}

	var i = 1
	for computer in computers:
		var json_data = {
			"scene": current_scene,
			"object": "computer",
			"position": {
				"x": computer.position.x,
				"y": computer.position.y
			}
		}
		all_json_data["computer" + str(i)] = json_data
		i = i + 1

	for robot in robots:
		var json_data = {
			"scene": current_scene,
			"object": "robot",
			"position": {
				"x": robot.position.x,
				"y": robot.position.y
			}
		}
		all_json_data["robot" + str(i)] = json_data
		i = i + 1

	for enemy in robot_enemies:
		var json_data = {
			"scene": current_scene,
			"object": "robot_enemy",
			"position": {
				"x": enemy.position.x,
				"y": enemy.position.y
			},
			"attack": enemy.enemy_attack,
			"defense": enemy.enemy_defense,
			"health": enemy.enemy_health,
			"dead": enemy.is_dead,
			"death_rotation": enemy.death_rotation
		}
		all_json_data["robot_enemy" + str(i)] = json_data
		i = i + 1
				
	var objects_to_save = JSON.stringify(all_json_data)
	
	if GameConfig.DEBUG:
		print(objects_to_save)
	var save_dir = DirAccess.open("user://")
	if save_dir:
		save_dir.make_dir(current_scene)
	var file = FileAccess.open("user://" + current_scene + "/" + current_scene + ".json", FileAccess.WRITE)
	file.store_line(objects_to_save)
	file.close()
	
func reinitializeLevel():
	if GameConfig.DEBUG:
		print("Reinitialize Level")
	var dir = DirAccess.open("res://World/Default/")
	var user_dir = DirAccess.open("user://")
	for level in ["level_1", "level_2", "level_3", "level_4"]:
		if user_dir:
			user_dir.make_dir(level)
		dir.copy("res://World/Default/%s/%s.json" % [level, level], "user://%s/%s.json" % [level, level])

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
		Player_data.player_attack = data.get("player_attack", randi_range(10, 15))
		Player_data.player_defense = data.get("player_defense", randi_range(10, 15))
		Player_data.player_nickname = data.get("player_nickname", "")

	else:
		if GameConfig.DEBUG:
			print("Save file not found!")
		Player_data.scene_path = "res://Scenes/Levels/%s/%s.tscn" % [Player_data_default.scene_start, Player_data_default.scene_start]
		Player_data.player_spawnpoint_position_x = Player_data_default.spawnpoint_position_x
		Player_data.player_spawnpoint_position_y = Player_data_default.spawnpoint_position_y
		Player_data.player_attack = randi_range(10, 15)
		Player_data.player_defense = randi_range(10, 15)
