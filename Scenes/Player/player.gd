extends CharacterBody2D

var liblevel = preload("res://Lib/liblevel.gd").new()

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

var main_menu = preload("res://UI/main_menu.tscn")
var menu_instance = null
var background_menu = null
var text_menu = null

var quit_button_menu = null
var play_button_menu = null

var speed = 70
var input_movement = Vector2.ZERO
var health = Player_data.player_health

var paused

var display_menu = false

var direction = 5

func _ready():
	menu_instance = main_menu.instantiate()
	add_child(menu_instance)		
	background_menu = menu_instance.get_node("Background")
	background_menu.position = Vector2(-576, -324)
	background_menu.visible = false
	background_menu.z_index = 10
	text_menu = menu_instance.get_node("MainMenuLayer")
	text_menu.visible = false
	
	play_button_menu = menu_instance.get_node("MainMenuLayer/Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonPlay")
	play_button_menu.visible = false

func _physics_process(_delta):
	input_move()

func _input(event):
		
	if event.is_action_pressed("ui_m"):
		if display_menu == false:
			background_menu = menu_instance.get_node("Background")
			background_menu.visible = true
			
			text_menu = menu_instance.get_node("MainMenuLayer")
			text_menu.visible = true
			display_menu = true
		else:
			background_menu = menu_instance.get_node("Background")
			background_menu.visible = false
			
			text_menu = menu_instance.get_node("MainMenuLayer")
			text_menu.visible = false
			display_menu = false

	if event.is_action_pressed("ui_b"):
		print("b key: build")
		EventBus.build_computer.emit(direction)
		
func input_move():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		if input_movement == Vector2(0, -1):
			direction = 8
		if input_movement == Vector2(0, 1):
			direction = 2
		if input_movement == Vector2(-1, 0):
			direction = 4
		if input_movement == Vector2(1, 0):
			direction = 6
											#
		anim_tree.set("parameters/Idle/blend_position", input_movement)
		anim_tree.set("parameters/Move/blend_position", input_movement)
		anim_state.travel("Move")
		velocity = input_movement * speed

	if input_movement == Vector2.ZERO:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO

	Player_data.player_pos_x = position.x
	Player_data.player_pos_y = position.y

	move_and_slide()


func _on_quit_pressed():
	# Save alls object of the current scene
	var computers = get_tree().get_nodes_in_group("computer")
	var robots = get_tree().get_nodes_in_group("robot")
	var current_scene = get_tree().get_current_scene().get_name()

	liblevel.saveAllObjects(current_scene, computers, robots )
			
	get_tree().quit()
