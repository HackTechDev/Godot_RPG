extends CanvasLayer

@onready var main: Control = $Main
@onready var settings: Control = $Settings

func load_game():
	if FileAccess.file_exists(Player_data.save_path):
		print("Save file found!")
		var file = FileAccess.open(Player_data.save_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		# Load the saved scene
		Player_data.scene_path = "res://Scenes//Levels/%s.tscn" % data["scene"]
		Player_data.player_spawnpoint_position_x = data["player_position"][0]
		Player_data.player_spawnpoint_position_y = data["player_position"][1]
		
	else:
		print("Save file not found!")
	
func _on_button_play_pressed():
	print("loading...")
	load_game()
	get_tree().change_scene_to_file(Player_data.scene_path)

func _on_button_settings_pressed():
	main.visible = false
	settings.visible = true

func _on_button_quit_pressed():
	get_tree().quit()

func _on_button_settings_back_pressed():
	main.visible = true
	settings.visible = false
