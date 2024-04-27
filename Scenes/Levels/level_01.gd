extends Node2D

@onready var player = $Player
@onready var computer_scene = preload("res://Objects/Computers/computer.tscn")
@onready var robot_scene = preload("res://Objects/Robots/robot.tscn")
	
func _ready():
	print("Scene: " + self.name)
	
	if Player_data.player_previous_scene == '':
			player.position.x = Player_data.player_spawnpoint_position_x
			player.position.y = Player_data.player_spawnpoint_position_y
	else:
		if Player_data.spawnpoint_next == "":
			player.position.x = Player_data.player_spawnpoint_position_x
			player.position.y = Player_data.player_spawnpoint_position_y
		else:
			var node_name =  "/root/level_01/spawnpoint_level_01_" + Player_data.spawnpoint_next + "_begin"
			player.position.x = get_node(node_name).position.x + Player_data.player_spawnpoint_position_x
			player.position.y = get_node(node_name).position.y + Player_data.player_spawnpoint_position_y 

	Player_data.player_previous_scene = self.name
	
	print("Load all objects")
	var datas
	# ~/.local/share/godot/app_userdata/rpg_v1/level_01.json
	if FileAccess.file_exists("user://level_01.json"):
		var file = FileAccess.open("user://level_01.json", FileAccess.READ)
		datas = JSON.parse_string(file.get_as_text())
		file.close()
	
	var data
	for key in datas:
		if datas[key].object == "computer":
			data = computer_scene.instantiate()
		if datas[key].object == "robot":
			data = robot_scene.instantiate()

		data.position.x = datas[key].position.x
		data.position.y = datas[key].position.y
		add_child(data)
