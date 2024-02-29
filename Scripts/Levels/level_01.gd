extends Node2D

@onready var player_scene = preload("res://Scenes/Player/player.tscn")
@onready var spawn_point = $entry/spawn_point
func _ready():
	on_player_spawn()

func on_player_spawn():
	var player = player_scene.instantiate()
	player.position = spawn_point.global_position
	add_child(player)
