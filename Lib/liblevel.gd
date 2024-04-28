extends Node

static var version = "1"

func displayVersion():
	return "LibLevel version: " + version

func savePlayer(data_to_save):
	var to_json = JSON.stringify(data_to_save)
	# ~/.local/share/godot/app_userdata/rpg_v1/rpg.json
	var file = FileAccess.open(Player_data.save_path, FileAccess.WRITE)
	file.store_line(to_json)
	file.close()
	
func saveAllObjects(current_scene, computers, robots ):
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
		all_json_data["computer" + str(i)] = json_data
		i = i + 1
				
	var objects_to_save = JSON.stringify(all_json_data)
	
	var file = FileAccess.open("user://" + current_scene + ".json", FileAccess.WRITE)
	file.store_line(objects_to_save)
	file.close()
	
func reinitializeLevel():
	var dir = DirAccess.open("res://World/Default/")
	print(dir.file_exists("level_01.json"))
	dir.copy("res://World/Default/level_01.json", "user://level_01.json")

func reinitializePlayer():
	DirAccess.remove_absolute(Player_data.save_path)

func load_game():
	# ~/.local/share/godot/app_userdata/rpg_v1/rpg.json
	if FileAccess.file_exists(Player_data.save_path):
		print("Character file found")
		var file = FileAccess.open(Player_data.save_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		# Load the saved scene
		Player_data.scene_path = "res://Scenes//Levels/%s.tscn" % data["scene"]
		Player_data.player_spawnpoint_position_x = data["player_position"][0]
		Player_data.player_spawnpoint_position_y = data["player_position"][1]
		
	else:
		print("Save file not found!")
		Player_data.scene_path = "res://Scenes//Levels/%s.tscn" % Player_data_default.scene_start
		Player_data.player_spawnpoint_position_x = Player_data_default.spawnpoint_position_x
		Player_data.player_spawnpoint_position_y = Player_data_default.spawnpoint_position_y
