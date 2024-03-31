extends Area2D



func _on_body_entered(body):
	if body.name == "Player":
		Player_data.computer += 1
		print("Computer collected :", Player_data.computer)
		queue_free()
