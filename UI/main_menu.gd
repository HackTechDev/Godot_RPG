extends CanvasLayer

var liblevel = preload("res://Lib/liblevel.gd").new()

@onready var main: Control = $Main
	
func _on_button_play_pressed():
	print("loading...")
	liblevel.load_game()
	get_tree().change_scene_to_file(Player_data.scene_path)

func _ready():
	print("Init Game")
	print(liblevel.displayVersion())
