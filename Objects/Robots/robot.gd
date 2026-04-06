extends RigidBody2D

@onready var interaction_label = $InteractionLabel

func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		Player_data.contact_object = self
		interaction_label.visible = true

func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		if Player_data.contact_object == self:
			Player_data.contact_object = null
		interaction_label.visible = false

func collect():
	Player_data.robot += 1
	Player_data.inventory.append({"type": "robot", "label": "Robot"})
	EventBus.item_collected.emit("Robot collecté !")
	queue_free()
