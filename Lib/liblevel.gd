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
	
