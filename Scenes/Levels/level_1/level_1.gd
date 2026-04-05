extends "res://Scenes/Levels/base_level.gd"

@onready var computer_scene = preload("res://Objects/Computers/computer.tscn")
@onready var robot_scene = preload("res://Objects/Robots/robot.tscn")
@onready var robot_enemy_scene = preload("res://Objects/RobotEnemy/robot_enemy.tscn")
var npc_scene = preload("res://Objects/NPC/npc.tscn")

func _ready():
	super._ready()

	print("Load all objects")
	var datas
	# ~/.local/share/godot/app_userdata/rpg_v1/level_1.json
	if FileAccess.file_exists("user://level_1/level_1.json"):
		var file = FileAccess.open("user://level_1/level_1.json", FileAccess.READ)
		datas = JSON.parse_string(file.get_as_text())
		file.close()
	
	if datas == null:
		datas = {}

	var data
	for key in datas:
		if datas[key].object == "computer":
			data = computer_scene.instantiate()
			data.add_to_group("computer")
		if datas[key].object == "robot":
			data = robot_scene.instantiate()
			data.add_to_group("robot")
		if datas[key].object == "robot_enemy":
			data = robot_enemy_scene.instantiate()
			data.add_to_group("robot_enemy")

		data.position.x = datas[key].position.x
		data.position.y = datas[key].position.y
		add_child(data)

		if datas[key].object == "robot_enemy" and datas[key].has("attack"):
			data.enemy_attack = int(datas[key].attack)
			data.enemy_defense = int(datas[key].defense)
			data.enemy_health = int(datas[key].health)
			if datas[key].get("dead", false):
				data.death_rotation = float(datas[key].get("death_rotation", PI / 2.0))
				data.apply_dead_state()

	EventBus.build_computer.connect(build_computer_event)
	_load_npcs()


func _load_npcs() -> void:
	var npc_dir = "res://Scenes/Levels/level_1/"
	var dir = DirAccess.open(npc_dir)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("npc_") and file_name.ends_with(".json"):
			var path = npc_dir + file_name
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var config = JSON.parse_string(file.get_as_text())
				file.close()
				if config is Dictionary:
					var npc = npc_scene.instantiate()
					npc.position = Vector2(config.position.x, config.position.y)
					add_child(npc)
					npc.setup(config)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	
func build_computer_event(direction):
	print("Build Computer")
	print(str(direction))
	var data
	data = computer_scene.instantiate()
	data.add_to_group("computer")
	
	var shift_x = 0
	var shift_y = 0
	
	if direction == 6:
		shift_x = 35
	if direction == 4:
		shift_x = -35
	if direction == 8:
		shift_y = -45
	if direction == 2:
		shift_y = 45
		
	var player = get_tree().get_first_node_in_group("player")
	data.position.x = player.position.x + shift_x
	data.position.y = player.position.y + shift_y

	add_child(data)
