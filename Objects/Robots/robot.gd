extends RigidBody2D

@onready var interaction_label = $InteractionLabel

func set_collision_shape(width: float, height: float, offset_x: float, offset_y: float) -> void:
	var col := $CollisionShape2D as CollisionShape2D
	var new_shape := RectangleShape2D.new()
	new_shape.size = Vector2(width, height)
	col.shape = new_shape
	col.position = Vector2(offset_x, offset_y)

func get_collision_data() -> Dictionary:
	var col := $CollisionShape2D as CollisionShape2D
	var sz: Vector2 = (col.shape as RectangleShape2D).size
	return { "collision_width": sz.x, "collision_height": sz.y, "collision_offset_x": col.position.x, "collision_offset_y": col.position.y }

func _process(_delta: float) -> void:
	var col := $CollisionShape2D as CollisionShape2D
	var half_h := (col.shape as RectangleShape2D).size.y * 0.5
	var pivot := Player_data.player_collision_offset_y + Player_data.player_collision_height * 0.5
	z_index = int(position.y + col.position.y + half_h - pivot)
	if GameConfig.debug_show_collision:
		queue_redraw()

func _draw() -> void:
	if GameConfig.debug_show_collision:
		var col := $CollisionShape2D as CollisionShape2D
		var sz: Vector2 = (col.shape as RectangleShape2D).size
		draw_rect(Rect2(col.position - sz * 0.5, sz), Color(1, 0, 0, 0.9), false, 1.5)

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
