extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		print("Player position: " + str(int(body.global_position.x)) + ", " + str(int(body.global_position.y)))
		print("Go to: " + self.name)
		get_tree().call_deferred("change_scene_to_file","res://Scenes/Levels/" + self.name + ".tscn")
