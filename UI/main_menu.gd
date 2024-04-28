extends CanvasLayer

var liblevel = preload("res://Lib/liblevel.gd").new()

@onready var main: Control = $Main
@onready var settings: Control = $Settings
	
func _on_button_play_pressed():
	print("loading...")
	liblevel.load_game()
	get_tree().change_scene_to_file(Player_data.scene_path)

func _on_button_settings_pressed():
	main.visible = false
	settings.visible = true

func _on_button_quit_pressed():
	get_tree().quit()

func _on_button_settings_back_pressed():
	main.visible = true
	settings.visible = false

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
