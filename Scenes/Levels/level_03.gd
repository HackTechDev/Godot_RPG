extends Node2D


@onready var player_scene = preload("res://Scenes/Player/player.tscn")
@onready var spawnpoint_level_01 = $spawnpoint_level_01

func _ready():
	print("Come from: " + Player_data.player_previous_scene)
	
	Player_data.player_previous_scene = self.name
	
	var player = player_scene.instantiate()
	player.position = spawnpoint_level_01.position
	add_child(player)
