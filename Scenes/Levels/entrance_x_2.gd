extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		var scene_next = self.name.get_slice("_", 1)

		Player_data.spawnpoint_current = self.name.get_slice("_", 2)
		Player_data.spawnpoint_next = self.name.get_slice("_", 3)

		var node_name = "/root/" + Player_data.player_previous_scene + "/spawnpoint_" + Player_data.player_previous_scene + "_" + Player_data.spawnpoint_current + "_begin"
		var spawnpoint_pos = get_node(node_name).global_position

		Player_data.player_spawnpoint_position_x = body.global_position.x - spawnpoint_pos.x
		Player_data.player_spawnpoint_position_y = body.global_position.y - spawnpoint_pos.y

		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Levels/level_" + scene_next + ".tscn")
