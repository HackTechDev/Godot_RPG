extends Node2D

class_name Player_instance

@onready var player_scene = preload("res://Scenes/Player/player.tscn")
@onready var spawn_point = $entry/spawn_point

# Called when the node enters the scene tree for the first time.
func _ready():
	on_player_spawn()

func on_player_spawn():
	var player = player_scene.instantiate()
	player.position = spawn_point.global_position
	add_child(player)
