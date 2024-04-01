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

	# Add computer
	var computers = []
	computers.append({"x": -128, "y": 440})
	computers.append({"x": -100, "y": 480})

	var robots = []
	robots.append({"x": -150, "y": 480})
	
	var computer
	var robot
	
	print(computers)
	
	for i in computers.size():
		print(computers[i])
		computer = computer_scene.instantiate()
		computer.position.x = computers[i].x
		computer.position.y = computers[i].y
		add_child(computer)
	
	for i in robots.size():
		print(robots[i])
		robot = robot_scene.instantiate()
		robot.position.x = robots[i].x
		robot.position.y = robots[i].y
		add_child(robot)

