extends Node2D

@onready var player = $Player
@onready var spawnpoint_level_01_start = $spawnpoint_level_01_start

func _ready():

	if Player_data.player_previous_scene == '':
		player.position = spawnpoint_level_01_start.position
	else:
		var node_name =  "/root/level_01/spawnpoint_level_01_" + Player_data.spawnpoint_next + "_begin"
		player.position.x = get_node(node_name).position.x
		player.position.y = get_node(node_name).position.y + Player_data.player_spawnpoint_position_y

	Player_data.player_previous_scene = self.name
