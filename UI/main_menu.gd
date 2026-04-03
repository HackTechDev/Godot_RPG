extends CanvasLayer

const SETTINGS_PATH = "user://settings.json"

var liblevel = preload("res://Lib/liblevel.gd").new()

@onready var main: Control = $Main
@onready var settings: Control = $Settings
@onready var help: Control = $Help
@onready var audio_settings: Control = $AudioSettings
@onready var controls_settings: Control = $ControlsSettings
@onready var check_music: CheckButton = $AudioSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckMusic
@onready var slider_volume: HSlider = $AudioSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SliderVolume
@onready var quit_dialog: ConfirmationDialog = $QuitDialog
@onready var music_neon_dream: AudioStreamPlayer = $"../Music_Neon_Dream"

	
func _on_button_play_pressed():
	print("loading...")
	liblevel.load_game()
	SceneTransition.change_scene(Player_data.scene_path)

func _on_button_settings_pressed():
	main.visible = false
	help.visible = false
	settings.visible = true

func _on_button_help_pressed():
	main.visible = false
	settings.visible = false
	help.visible = true
	
func _on_button_quit_pressed():
	quit_dialog.popup_centered()

func _on_quit_dialog_confirmed():
	print("Save Player")
	liblevel.savePlayer(data_to_save())

	print("Save all objects")
	var computers = get_tree().get_nodes_in_group("computer")
	var robots = get_tree().get_nodes_in_group("robot")
	var robot_enemies = get_tree().get_nodes_in_group("robot_enemy")
	var current_scene = get_tree().get_current_scene().get_name()
	liblevel.saveAllObjects(current_scene, computers, robots, robot_enemies)

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

func _on_button_controls_pressed():
	settings.visible = false
	controls_settings.visible = true

func _on_button_controls_back_pressed():
	controls_settings.visible = false
	settings.visible = true

func _on_check_music_toggled(toggled_on: bool):
	music_neon_dream.stream_paused = !toggled_on
	_save_audio_settings()

func _on_slider_volume_value_changed(value: float):
	music_neon_dream.volume_db = linear_to_db(maxf(value, 0.01) / 100.0)
	_save_audio_settings()

func _save_audio_settings():
	var data = {
		"music_paused": music_neon_dream.stream_paused,
		"volume_linear": db_to_linear(music_neon_dream.volume_db)
	}
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	file.close()

func _load_audio_settings():
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		return
	music_neon_dream.stream_paused = data.get("music_paused", false)
	music_neon_dream.volume_db = linear_to_db(maxf(data.get("volume_linear", 0.8), 0.01))

func _on_button_settings_back_pressed():
	main.visible = true
	settings.visible = false
	help.visible = false
	audio_settings.visible = false
	controls_settings.visible = false

func _on_button_help_back_pressed() -> void:
	main.visible = true
	settings.visible = false
	help.visible = false
	
	
func _on_reinitialize_pressed():
	print("Reinitialize")
	liblevel.reinitializePlayer()
	liblevel.reinitializeLevel()
	Player_data.player_previous_scene = ""
	Player_data.spawnpoint_current = ""
	Player_data.spawnpoint_next = ""
	Player_data.scene_path = ""
	Player_data.player_pos_x = 0
	Player_data.player_pos_y = 0
	Player_data.computer = 0
	Player_data.robot = 0
	Player_data.inventory = []
	Player_data.contact_object = null
	get_tree().paused = false
	SceneTransition.change_scene("res://UI/main_menu.tscn")
	
func _ready():
	print("Init Game")
	print(liblevel.displayVersion())
	
	get_tree().set_auto_accept_quit(false)
	
	music_neon_dream.play()
	_load_audio_settings()
	SceneTransition.fade_in()

func data_to_save():
	return {
		"player_position" : [Player_data.player_pos_x, Player_data.player_pos_y],
		"player_facing" : Player_data.player_facing,
		"scene": Player_data.player_previous_scene,
		"player_health": Player_data.player_health
	}

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("You must quit via the quit button")
