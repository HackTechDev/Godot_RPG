extends Node2D


@onready var player_scene = preload("res://Scenes/Player/player.tscn")

func _ready():
	Player_data.player_previous_scene = self.name

	var player = player_scene.instantiate()
	var node_name =  "/root/level_04/spawnpoint_level_04_" + Player_data.spawnpoint_next + "_begin"

	player.position.x = get_node(node_name).position.x + Player_data.player_spawnpoint_position_x - 12
	player.position.y = get_node(node_name).position.y + Player_data.player_spawnpoint_position_y

	add_child(player)
