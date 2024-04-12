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



	#var objects = []
	#objects.append({"id": 1, "type": "computer", "x": -128, "y": 440})
	#objects.append({"id": 2, "type": "computer", "x": -100, "y": 480})
	#objects.append({"id": 1, "type": "robot","x": -150, "y": 480})
	#
	#print(objects)
	#
	#var json = JSON.new()
	#var to_json = json.stringify(objects)
	#
	# ~/.local/share/godot/app_userdata/rpg_v1/level_01.json
	#var file = FileAccess.open( "user://level_01.json", FileAccess.WRITE)
	#file.store_line(to_json)
	#file.close()
		#
	#var object
	#for i in objects.size():
		#if objects[i].type == "computer":
			#object = computer_scene.instantiate()
		#if objects[i].type == "robot":
			#object = robot_scene.instantiate()
	#
		#object.position.x = objects[i].x
		#object.position.y = objects[i].y
		#add_child(object)
