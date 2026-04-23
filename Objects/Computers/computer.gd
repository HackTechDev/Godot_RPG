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
	Player_data.computer += 1
	Player_data.inventory.append({"type": "computer", "label": "Ordinateur"})
	EventBus.item_collected.emit("Ordinateur collecté !")
	_mark_mission_started()
	queue_free()

func _mark_mission_started() -> void:
	if Player_data.current_mission_id == "":
		return
	var file := FileAccess.open("user://current_mission.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data is Dictionary and data.get("started", false):
			return
	var out := FileAccess.open("user://current_mission.json", FileAccess.WRITE)
	if out:
		out.store_line(JSON.stringify({"mission_id": Player_data.current_mission_id, "started": true, "mission_elapsed_real": 0.0}))
		out.close()
