extends "res://Scenes/Levels/base_level.gd"

@onready var computer_scene = preload("res://Objects/Computers/computer.tscn")
@onready var robot_scene = preload("res://Objects/Robots/robot.tscn")
@onready var robot_enemy_scene = preload("res://Objects/RobotEnemy/robot_enemy.tscn")

func _ready():
	super._ready()
	_load_objects()

func _load_objects():
	var datas = _read_level_json("user://level_02.json", "res://World/Default/level_02.json")
	for key in datas:
		var data
		if datas[key].object == "computer":
			data = computer_scene.instantiate()
			data.add_to_group("computer")
		elif datas[key].object == "robot":
			data = robot_scene.instantiate()
			data.add_to_group("robot")
		elif datas[key].object == "robot_enemy":
			data = robot_enemy_scene.instantiate()
			data.add_to_group("robot_enemy")
		else:
			continue
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

func _read_level_json(save_path: String, default_path: String) -> Dictionary:
	for path in [save_path, default_path]:
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			var datas = JSON.parse_string(file.get_as_text())
			file.close()
			if datas != null:
				return datas
	return {}
