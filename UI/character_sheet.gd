extends CanvasLayer

@onready var label_health = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelHealth
@onready var label_computers = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelComputers
@onready var label_robots = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelRobots
@onready var label_scene = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelScene
@onready var label_inventory = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelInventory

func refresh():
	label_health.text = "Santé : " + str(Player_data.player_health)
	label_computers.text = "Ordinateurs : " + str(Player_data.computer)
	label_robots.text = "Robots : " + str(Player_data.robot)
	label_scene.text = "Zone : " + Player_data.player_previous_scene

	if Player_data.inventory.is_empty():
		label_inventory.text = "(vide)"
	else:
		var lines = []
		for item in Player_data.inventory:
			lines.append("- " + item["label"])
		label_inventory.text = "\n".join(lines)

func _on_button_close_pressed():
	visible = false
