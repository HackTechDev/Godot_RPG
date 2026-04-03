extends CharacterBody2D

var liblevel = preload("res://Lib/liblevel.gd").new()

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var footstep = $Footstep

var main_menu = preload("res://UI/main_menu.tscn")
var menu_instance = null
var background_menu = null
var text_menu = null

var quit_button_menu = null
var play_button_menu = null

var character_sheet_scene = preload("res://UI/character_sheet.tscn")
var character_sheet_instance = null

var hud_scene = preload("res://UI/hud.tscn")
var hud_instance = null

var notification_scene = preload("res://UI/notification.tscn")
var notification_instance = null

var speed = 70
var input_movement = Vector2.ZERO
var health = Player_data.player_health

var display_menu = false
var direction = 5

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("player")

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

	character_sheet_instance = character_sheet_scene.instantiate()
	add_child(character_sheet_instance)

	hud_instance = hud_scene.instantiate()
	add_child(hud_instance)

	notification_instance = notification_scene.instantiate()
	add_child(notification_instance)

	SceneTransition.fade_in()

func _physics_process(_delta):
	input_move()

func _input(event):
	if event.is_action_pressed("ui_m"):
		display_menu = !display_menu
		background_menu.visible = display_menu
		text_menu.visible = display_menu
		get_tree().paused = display_menu
		if not display_menu:
			_auto_save_objects()

	if event.is_action_pressed("ui_b"):
		print("b key: build")
		EventBus.build_computer.emit(direction)

	if event.is_action_pressed("ui_t"):
		if is_instance_valid(Player_data.contact_object):
			Player_data.contact_object.collect()

	if event.is_action_pressed("ui_r"):
		if is_instance_valid(Player_data.contact_object):
			Player_data.contact_object.apply_central_impulse(_facing_to_vector() * 180.0)

	if event.is_action_pressed("ui_p"):
		character_sheet_instance.visible = !character_sheet_instance.visible
		if character_sheet_instance.visible:
			character_sheet_instance.refresh()

func input_move():
	if display_menu:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_movement != Vector2.ZERO:
		movement_sounds()
		if input_movement == Vector2(0, -1):
			direction = 8
		if input_movement == Vector2(0, 1):
			direction = 2
		if input_movement == Vector2(-1, 0):
			direction = 4
		if input_movement == Vector2(1, 0):
			direction = 6

		anim_tree.set("parameters/Idle/blend_position", input_movement)
		anim_tree.set("parameters/Move/blend_position", input_movement)
		anim_state.travel("Move")
		velocity = input_movement * speed

	if input_movement == Vector2.ZERO:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO

	Player_data.player_facing = direction
	Player_data.player_pos_x = position.x
	Player_data.player_pos_y = position.y

	move_and_slide()

func _auto_save_objects():
	var computers = get_tree().get_nodes_in_group("computer")
	var robots = get_tree().get_nodes_in_group("robot")
	var current_scene = get_tree().get_current_scene().get_name()
	liblevel.saveAllObjects(current_scene, computers, robots)

func _facing_to_vector() -> Vector2:
	match direction:
		2: return Vector2(0, 1)
		4: return Vector2(-1, 0)
		6: return Vector2(1, 0)
		8: return Vector2(0, -1)
	return Vector2.ZERO

func movement_sounds():
	var IS_FOOTSTEP_SOUND_PLAYING = false
	if footstep.is_playing():
		IS_FOOTSTEP_SOUND_PLAYING = true
	if !IS_FOOTSTEP_SOUND_PLAYING:
		footstep.play()
