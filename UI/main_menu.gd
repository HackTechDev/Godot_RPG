extends CanvasLayer

var liblevel = preload("res://Lib/liblevel.gd").new()

@onready var main: Control = $Main
@onready var settings: Control = $Settings
@onready var help: Control = $Help

	
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
	print("Quit")
	
	# Save the player
	liblevel.savePlayer(data_to_save())
	
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
	
func _ready():
	print("Init Game")
	print(liblevel.displayVersion())


func data_to_save():	
	return {
		"player_position" : [Player_data.player_pos_x, Player_data.player_pos_y],
		"scene": Player_data.player_previous_scene
	}
