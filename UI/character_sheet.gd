extends CanvasLayer

@onready var label_health = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelHealth
@onready var label_computers = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelComputers
@onready var label_robots = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelRobots
@onready var label_scene = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelScene

func refresh():
	label_health.text = "Santé : " + str(Player_data.player_health)
	label_computers.text = "Ordinateurs : " + str(Player_data.computer)
	label_robots.text = "Robots : " + str(Player_data.robot)
	label_scene.text = "Zone : " + str(Player_data.spawnpoint_current)

func _on_button_close_pressed():
	visible = false
