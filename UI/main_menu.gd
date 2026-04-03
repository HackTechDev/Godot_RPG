extends CanvasLayer

var liblevel = preload("res://Lib/liblevel.gd").new()

@onready var main: Control = $Main
@onready var settings: Control = $Settings
@onready var help: Control = $Help
@onready var audio_settings: Control = $AudioSettings
@onready var check_music: CheckButton = $AudioSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckMusic
@onready var slider_volume: HSlider = $AudioSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SliderVolume
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

func _on_button_audio_pressed():
	settings.visible = false
	audio_settings.visible = true
	check_music.button_pressed = !music_neon_dream.stream_paused
	slider_volume.value = db_to_linear(music_neon_dream.volume_db) * 100.0

func _on_button_audio_back_pressed():
	audio_settings.visible = false
	settings.visible = true

func _on_check_music_toggled(toggled_on: bool):
	music_neon_dream.stream_paused = !toggled_on

func _on_slider_volume_value_changed(value: float):
	music_neon_dream.volume_db = linear_to_db(maxf(value, 0.01) / 100.0)

func _on_button_settings_back_pressed():
	main.visible = true
	settings.visible = false
	help.visible = false
	audio_settings.visible = false

func _on_button_help_back_pressed() -> void:
	main.visible = true
	settings.visible = false
	help.visible = false
	
	
func _on_reinitialize_pressed():
	print("Reinitialize")
	liblevel.reinitializePlayer()
	liblevel.reinitializeLevel()
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
	
func _ready():
	print("Init Game")
	print(liblevel.displayVersion())
	
	get_tree().set_auto_accept_quit(false)
	
	music_neon_dream.play()

func data_to_save():	
	return {
		"player_position" : [Player_data.player_pos_x, Player_data.player_pos_y],
		"player_facing" : Player_data.player_facing,
		"scene": Player_data.player_previous_scene
	}

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("You must quit via the quit button")
