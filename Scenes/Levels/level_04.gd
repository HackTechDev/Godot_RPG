extends Node2D


@onready var player_scene = preload("res://Scenes/Player/player.tscn")

func _ready():
	print(self.name)
		
	Player_data.player_previous_scene = self.name

	var player = player_scene.instantiate()
	
	if Player_data.spawnpoint_next == "":
		player.position.x = Player_data.player_spawnpoint_position_x
		player.position.y = Player_data.player_spawnpoint_position_y
	else:
		var node_name =  "/root/level_04/spawnpoint_level_04_" + Player_data.spawnpoint_next + "_begin"

		player.position.x = get_node(node_name).position.x + Player_data.player_spawnpoint_position_x - 12
		player.position.y = get_node(node_name).position.y + Player_data.player_spawnpoint_position_y

	add_child(player)
