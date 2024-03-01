extends Node2D

@onready var player = $Player
@onready var spawnpoint_level_03 = $spawnpoint_level_03
@onready var spawnpoint_level_04 = $spawnpoint_level_04
@onready var spawnpoint_level_01_start = $spawnpoint_level_01_start

func _ready():
	
	print(str(int(spawnpoint_level_04.global_position.x)) + ", " + str(int(spawnpoint_level_04.global_position.y)))
	
	if Player_data.player_previous_scene == '':
		player.position = spawnpoint_level_01_start.position
	else:
		print("Come from: " + Player_data.player_previous_scene)
		
		if Player_data.player_previous_scene == "level_03":
			player.position = spawnpoint_level_03.position	
		if Player_data.player_previous_scene == "level_04":
			player.position = spawnpoint_level_04.position	
		
	Player_data.player_previous_scene = self.name
