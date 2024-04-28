extends CharacterBody2D

var liblevel = preload("res://Lib/liblevel.gd").new()

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
	liblevel.savePlayer(data_to_save())

	# Save alls object of the current scene
	var computers = get_tree().get_nodes_in_group("computer")
	var robots = get_tree().get_nodes_in_group("robot")
	var current_scene = get_tree().get_current_scene().get_name()

	liblevel.saveAllObjects(current_scene, computers, robots )
			
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

func _on_button_reinitialize_pressed():
	print("Reinitialize")
	match OS.get_name():
		"Linux":
			print("Linux platform")
			liblevel.reinitializePlayer()
			liblevel.reinitializeLevel()
			get_tree().quit()
		_:
			print("Other platform")
	
