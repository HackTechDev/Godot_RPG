extends Node2D

@onready var player = $Player

func _ready():
	print("Scene: " + self.name)
	
	if Player_data.player_previous_scene == '':
			player.position.x = Player_data.player_spawnpoint_position_x
			player.position.y = Player_data.player_spawnpoint_position_y
	else:
		if Player_data.spawnpoint_next == "":
			player.position.x = Player_data.player_spawnpoint_position_x
			player.position.y = Player_data.player_spawnpoint_position_y
		else:
			var node_name =  "/root/level_01/spawnpoint_level_01_" + Player_data.spawnpoint_next + "_begin"
			player.position.x = get_node(node_name).position.x + Player_data.player_spawnpoint_position_x
			player.position.y = get_node(node_name).position.y + Player_data.player_spawnpoint_position_y 

	Player_data.player_previous_scene = self.name
