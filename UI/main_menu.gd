extends CanvasLayer

var liblevel = preload("res://Lib/liblevel.gd").new()

@onready var main: Control = $Main
@onready var settings: Control = $Settings
@onready var help: Control = $Help
@onready var music_neon_dream: AudioStreamPlayer = $"../Music_Neon_Dream"

	
func _on_button_play_pressed():
	print("loading...")
	liblevel.load_game()
	get_tree().change_scene_to_file(Player_data.scene_path)

func _on_button_settings_pressed():
	main.visible = false
	help.visible = false
	settings.visible = true

func _on_button_help_pressed():
	main.visible = false
	settings.visible = false
	help.visible = true
	
func _on_button_quit_pressed():
	# ~/.local/share/godot/app_userdata/rpg_v1/rpg.json
	
	# Save the player
	print("Save Player")
	liblevel.savePlayer(data_to_save())
	
	# Save all objects of the current scene
	print("Salle all objects")
	var computers = get_tree().get_nodes_in_group("computer")
	var robots = get_tree().get_nodes_in_group("robot")
	var current_scene = get_tree().get_current_scene().get_name()

	liblevel.saveAllObjects(current_scene, computers, robots)
	
	print("Quit")
	get_tree().quit()

func _on_button_settings_back_pressed():
	main.visible = true
	settings.visible = false
	help.visible = false

func _on_button_help_back_pressed() -> void:
	main.visible = true
	settings.visible = false
	help.visible = false
	
	
func _on_reinitialize_pressed():
	print("Reinitialize")
	match OS.get_name():
		"Linux":
			print("Linux platform")
			liblevel.reinitializePlayer()
			liblevel.reinitializeLevel()
		_:
			print("Other platform")
	
	get_tree().quit()
	
func _ready():
	print("Init Game")
	print(liblevel.displayVersion())
	music_neon_dream.play()

func data_to_save():	
	return {
		"player_position" : [Player_data.player_pos_x, Player_data.player_pos_y],
		"player_facing" : Player_data.player_facing,
		"scene": Player_data.player_previous_scene
	}
