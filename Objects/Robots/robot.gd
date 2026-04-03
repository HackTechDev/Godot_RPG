extends RigidBody2D

@onready var interaction_label = $InteractionLabel

func _on_interaction_area_body_entered(body):
	if body.name == "Player":
		Player_data.contact_object = self
		interaction_label.visible = true

func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		if Player_data.contact_object == self:
			Player_data.contact_object = null
		interaction_label.visible = false

func collect():
	Player_data.robot += 1
	Player_data.inventory.append({"type": "robot", "label": "Robot"})
	print("Robot collected :", Player_data.robot)
	queue_free()
