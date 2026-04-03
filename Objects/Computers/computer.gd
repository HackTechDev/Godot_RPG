extends RigidBody2D

func _on_interaction_area_body_entered(body):
	if body.name == "Player":
		Player_data.contact_object = self

func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		if Player_data.contact_object == self:
			Player_data.contact_object = null

func collect():
	Player_data.computer += 1
	print("Computer collected :", Player_data.computer)
	queue_free()
