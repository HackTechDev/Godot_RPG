extends RigidBody2D

@onready var interaction_label = $InteractionLabel

func _process(_delta: float) -> void:
	if GameConfig.debug_show_collision:
		queue_redraw()

func _draw() -> void:
	if GameConfig.debug_show_collision:
		var col_pos: Vector2 = $CollisionShape2D.position
		var radius: float = ($CollisionShape2D.shape as CircleShape2D).radius
		draw_arc(col_pos, radius, 0.0, TAU, 32, Color(1, 0, 0, 0.9), 1.5)

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
	_mark_mission_started()
	queue_free()

func _mark_mission_started() -> void:
	if Player_data.current_mission_id == "":
		return
	var path := "user://current_mission.json"
	var state: Dictionary = {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			state = parsed
	if state.get("started", false):
		return
	state["mission_id"] = Player_data.current_mission_id
	state["started"] = true
	if not state.has("mission_elapsed_real"):
		state["mission_elapsed_real"] = 0.0
	var out := FileAccess.open(path, FileAccess.WRITE)
	if out:
		out.store_line(JSON.stringify(state))
		out.close()
