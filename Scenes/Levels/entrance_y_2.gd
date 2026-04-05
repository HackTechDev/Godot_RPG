extends Area2D

var liblevel = preload("res://Lib/liblevel.gd").new()

func _on_body_entered(body):
	if body.is_in_group("player"):
		var scene_next = self.name.get_slice("_", 1)

		Player_data.spawnpoint_current = self.name.get_slice("_", 2)
		Player_data.spawnpoint_next = self.name.get_slice("_", 3)

		var node_name = "/root/" + Player_data.player_previous_scene + "/spawnpoint_" + Player_data.player_previous_scene + "_" + Player_data.spawnpoint_current + "_begin"
		var spawnpoint_pos = get_node(node_name).global_position

		Player_data.player_spawnpoint_position_x = body.global_position.x - spawnpoint_pos.x
		Player_data.player_spawnpoint_position_y = body.global_position.y - spawnpoint_pos.y

		var computers = get_tree().get_nodes_in_group("computer")
		var robots = get_tree().get_nodes_in_group("robot")
		var robot_enemies = get_tree().get_nodes_in_group("robot_enemy")
		liblevel.saveAllObjects(Player_data.player_previous_scene, computers, robots, robot_enemies)
		liblevel.savePlayer({
			"player_position": [Player_data.player_pos_x, Player_data.player_pos_y],
			"player_facing": Player_data.player_facing,
			"scene": Player_data.player_previous_scene,
			"player_health": Player_data.player_health,
			"player_attack": Player_data.player_attack,
			"player_defense": Player_data.player_defense
		})

		SceneTransition.change_scene("res://Scenes/Levels/level_" + scene_next + "/level_" + scene_next + ".tscn")
