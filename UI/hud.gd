extends CanvasLayer

@onready var label_health = $Panel/Margin/VBox/LabelHealth
@onready var label_computers = $Panel/Margin/VBox/LabelComputers
@onready var label_robots = $Panel/Margin/VBox/LabelRobots
@onready var label_zone = $Panel/Margin/VBox/LabelZone

func _process(_delta):
	label_health.text = "Santé: " + str(Player_data.player_health)
	label_computers.text = "Ordinateurs: " + str(Player_data.computer)
	label_robots.text = "Robots: " + str(Player_data.robot)
	label_zone.text = "Zone: " + Player_data.player_previous_scene
