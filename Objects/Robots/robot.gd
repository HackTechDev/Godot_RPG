extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		Player_data.robot += 1
		print("Robot collected :", Player_data.robot)
		queue_free()
