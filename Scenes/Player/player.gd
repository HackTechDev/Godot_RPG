extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var pause_menu = $PauseMenu
@onready var settings_menu = $SettingsMenu

var speed = 70
var input_movement = Vector2.ZERO
var health = Player_data.player_health

var paused

func _ready():
	pass

func _physics_process(_delta):
	input_move()

func _input(event):
	if !pause_menu.visible:
		if event.is_action_pressed("ui_pause"):
			get_tree().paused = true
			pause_menu.visible = true
			set_physics_process(false)
			paused = true
			
				
func input_move():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_movement)
		anim_tree.set("parameters/Move/blend_position", input_movement)
		anim_state.travel("Move")
		velocity = input_movement * speed

	if input_movement == Vector2.ZERO:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO

	move_and_slide()


func _on_resume_pressed():
	print("resume")
	pause_menu.visible = false
	get_tree().paused = false
	paused = false
	set_process_input(true)
	set_physics_process(true)

func _on_settings_pressed():
	pause_menu.visible = false
	settings_menu.visible = true
	print("Settings")

func _on_quit_pressed():
	print("Quit")
	
	# Save the player
	var to_json = JSON.stringify(data_to_save())
	# ~/.local/share/godot/app_userdata/rpg_v1/rpg.json
	var file = FileAccess.open(Player_data.save_path, FileAccess.WRITE)
	file.store_line(to_json)
	file.close()

	
	# Save alls object of the current scene
	var all_json_data = {}
	
	var computers = get_tree().get_nodes_in_group("computer")
	var robots = get_tree().get_nodes_in_group("robot")
	var current_scene = get_tree().get_current_scene().get_name()
	print(current_scene)
	var i = 1
	for computer in computers:
		var json_data = {
			"scene": current_scene,
			"object": "computer",
			"position": {
				"x": computer.position.x,
				"y": computer.position.y
			}	
		}
		all_json_data["computer" + str(i)] = json_data
		i = i + 1
		
	
	for robot in robots:
		var json_data = {
			"scene": current_scene,
			"object": "robot",
			"position": {
				"x": robot.position.x,
				"y": robot.position.y
			}	
		}
		all_json_data["computer" + str(i)] = json_data
		i = i + 1
				
	var objects_to_save = JSON.stringify(all_json_data)
	
	file = FileAccess.open("user://" + current_scene + ".json", FileAccess.WRITE)
	file.store_line(objects_to_save)
	file.close()
	
			
	get_tree().quit()

func _on_back_pressed():
	pause_menu.visible = true
	settings_menu.visible = false
	print("Back")

func data_to_save():
	return {
		"player_position" : [position.x, position.y],
		"scene": Player_data.player_previous_scene
	}
