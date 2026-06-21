extends CharacterBody2D

var npc_id: String        = ""
var npc_name: String      = ""
var dialogue: Dictionary  = {}
var is_dead: bool         = false
var death_rotation: float = 0.0

@onready var name_label: Label = $NameLabel
@onready var interaction_label: Label = $InteractionLabel

func _ready() -> void:
	add_to_group("npc")

func _process(_delta: float) -> void:
	if GameConfig.debug_show_collision:
		queue_redraw()

func _draw() -> void:
	if GameConfig.debug_show_collision:
		var col := $CollisionShape2D
		var col_pos: Vector2  = col.position
		var col_size: Vector2 = (col.shape as RectangleShape2D).size
		draw_rect(Rect2(col_pos - col_size / 2.0, col_size), Color(1, 0, 0, 0.9), false, 1.5)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	death_rotation = PI / 2.0 * (1 if randi_range(0, 1) == 0 else -1)
	var spr := get_node_or_null("Sprite2D") as Node2D
	if spr:
		var tw := create_tween()
		tw.tween_property(spr, "rotation", death_rotation, 0.3)
	name_label.visible        = false
	interaction_label.visible = false

func apply_dead_state() -> void:
	is_dead = true
	var spr := get_node_or_null("Sprite2D") as Node2D
	if spr:
		spr.rotation = death_rotation
	name_label.visible        = false
	interaction_label.visible = false

func setup(config: Dictionary) -> void:
	npc_id = config.get("id", "npc_00")
	npc_name = config.get("name", "NPC")
	dialogue = config.get("dialogue", {})
	name_label.text = npc_name
	if config.get("dead", false):
		death_rotation = float(config.get("death_rotation", PI / 2.0))
		apply_dead_state()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Player_data.contact_npc = self
		interaction_label.visible = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if Player_data.contact_npc == self:
			Player_data.contact_npc = null
		interaction_label.visible = false
