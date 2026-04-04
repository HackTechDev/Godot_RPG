extends Node2D

@onready var player_scene = preload("res://Scenes/Player/player.tscn")
var _indicator_script = preload("res://Scenes/Levels/spawnpoint_indicator.gd")

func _ready():
	print("Scene: " + self.name)
	Player_data.player_previous_scene = self.name
	SceneTransition.fade_in()
	_add_spawnpoint_visuals()

	var player = player_scene.instantiate()
	_place_player(player)
	add_child(player)

func _add_spawnpoint_visuals():
	for child in get_children():
		if child is Marker2D and child.name.begins_with("spawnpoint_"):
			var indicator = Node2D.new()
			indicator.set_script(_indicator_script)
			child.add_child(indicator)

func _place_player(player):
	if Player_data.spawnpoint_next == "":
		player.position.x = Player_data.player_spawnpoint_position_x
		player.position.y = Player_data.player_spawnpoint_position_y
	else:
		var node_name = "/root/%s/spawnpoint_%s_%s_begin" % [self.name, self.name, Player_data.spawnpoint_next]
		player.position = get_node(node_name).position + Vector2(
			Player_data.player_spawnpoint_position_x,
			Player_data.player_spawnpoint_position_y
		)
