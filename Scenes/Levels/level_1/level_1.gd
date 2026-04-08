extends "res://Scenes/Levels/base_level.gd"

func _ready():
	super._ready()
	EventBus.build_computer.connect(build_computer_event)


func build_computer_event(direction):
	var data = _computer_scene.instantiate()
	data.add_to_group("computer")

	var shift_x = 0
	var shift_y = 0
	if direction == 6: shift_x =  35
	if direction == 4: shift_x = -35
	if direction == 8: shift_y = -45
	if direction == 2: shift_y =  45

	var player = get_tree().get_first_node_in_group("player")
	data.position = player.position + Vector2(shift_x, shift_y)
	add_child(data)
