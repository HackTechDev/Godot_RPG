extends Area2D



func _on_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Scenes/Levels/level_02.tscn")


func _on_checkpoint_body_entered(body):
	if body.name == "Player":
		Player_data.player_position = body.global_position
		print(Player_data.player_position)
