extends CanvasLayer

signal sheet_requested
signal setting_requested
signal home_requested

@onready var label_nickname = $Panel/Margin/VBox/LabelNickname
@onready var label_health = $Panel/Margin/VBox/LabelHealth
@onready var label_computers = $Panel/Margin/VBox/LabelComputers
@onready var label_robots = $Panel/Margin/VBox/LabelRobots
@onready var label_zone     = $Panel/Margin/VBox/LabelZone
@onready var label_position = $Panel/Margin/VBox/LabelPosition

func _process(_delta):
	label_nickname.text = "Pseudo: " + Player_data.player_nickname
	label_health.text = "Santé: " + str(Player_data.player_health)
	label_computers.text = "Ordinateurs: " + str(Player_data.computer)
	label_robots.text = "Robots: " + str(Player_data.robot)
	label_zone.text = "Zone: " + Player_data.player_previous_scene
	label_position.text = "Pos: %d, %d" % [Player_data.player_pos_x, Player_data.player_pos_y]

func _on_btn_sheet_pressed():
	sheet_requested.emit()

func _on_btn_setting_pressed():
	setting_requested.emit()

func _on_btn_home_pressed():
	home_requested.emit()
