extends CanvasLayer

var liblevel = preload("res://Lib/liblevel.gd").new()

func show_game_over():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	get_tree().paused = true

func _on_restart_pressed():
	get_tree().paused = false
	liblevel.reinitializePlayer()
	liblevel.reinitializeLevel()
	Player_data.player_previous_scene = ""
	Player_data.scene_path = ""
	Player_data.player_pos_x = 0
	Player_data.player_pos_y = 0
	Player_data.player_health = 4
	Player_data.player_attack = randi_range(10, 15)
	Player_data.player_defense = randi_range(10, 15)
	Player_data.computer = 0
	Player_data.robot = 0
	Player_data.inventory = []
	Player_data.contact_object = null
	Player_data.contact_enemy = null
	Player_data.goto_character_creation = true
	SceneTransition.change_scene("res://UI/main_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
