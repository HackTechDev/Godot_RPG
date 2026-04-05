extends CharacterBody2D

var npc_id: String = ""
var npc_name: String = ""
var dialogue: Dictionary = {}

@onready var name_label: Label = $NameLabel
@onready var interaction_label: Label = $InteractionLabel

func setup(config: Dictionary) -> void:
	npc_id = config.get("id", "npc_00")
	npc_name = config.get("name", "NPC")
	dialogue = config.get("dialogue", {})
	name_label.text = npc_name

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Player_data.contact_npc = self
		interaction_label.visible = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if Player_data.contact_npc == self:
			Player_data.contact_npc = null
		interaction_label.visible = false
