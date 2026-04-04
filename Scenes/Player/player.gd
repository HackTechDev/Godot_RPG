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

var game_over_scene = preload("res://UI/game_over.tscn")
var game_over_instance = null
var _game_over_shown = false

var speed = 70
var input_movement = Vector2.ZERO
var health = Player_data.player_health

var display_menu = false
var direction = 5

var in_combat: bool = false
var combat_enemy = null
var player_combat_label: Label = null
var _combat_busy: bool = false

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
	play_button_menu.text = "Back to the game"
	play_button_menu.pressed.disconnect(text_menu._on_button_play_pressed)
	play_button_menu.pressed.connect(_close_menu)

	character_sheet_instance = character_sheet_scene.instantiate()
	add_child(character_sheet_instance)

	hud_instance = hud_scene.instantiate()
	add_child(hud_instance)
	hud_instance.sheet_requested.connect(_on_hud_sheet_requested)
	hud_instance.setting_requested.connect(_on_hud_setting_requested)
	hud_instance.home_requested.connect(_on_hud_home_requested)

	notification_instance = notification_scene.instantiate()
	add_child(notification_instance)

	game_over_instance = game_over_scene.instantiate()
	add_child(game_over_instance)

	player_combat_label = Label.new()
	player_combat_label.position = Vector2(-55, -78)
	player_combat_label.visible = false
	player_combat_label.z_index = 10
	player_combat_label.add_theme_font_size_override("font_size", 11)
	player_combat_label.add_theme_constant_override("outline_size", 2)
	player_combat_label.add_theme_color_override("font_outline_color", Color.BLACK)
	player_combat_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	add_child(player_combat_label)

	SceneTransition.fade_in()

func _physics_process(_delta):
	input_move()

func _process(_delta):
	if in_combat and is_instance_valid(combat_enemy):
		_update_combat_label_positions()
	if not _game_over_shown and Player_data.player_health <= 0:
		_game_over_shown = true
		if in_combat:
			_end_combat()
		game_over_instance.show_game_over()

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

	if event.is_action_pressed("ui_c"):
		print("C pressed | in_combat=", in_combat, " | contact_enemy=", Player_data.contact_enemy)
		if in_combat:
			_attempt_flee()
		elif is_instance_valid(Player_data.contact_enemy):
			_start_combat(Player_data.contact_enemy)
		else:
			print("C: pas d'ennemi à portée")

	if event.is_action_pressed("ui_a"):
		_on_attack_key()

func input_move():
	if display_menu or in_combat:
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

func _close_menu():
	display_menu = false
	background_menu.visible = false
	text_menu.visible = false
	get_tree().paused = false
	_auto_save_objects()

func _auto_save_objects():
	var computers = get_tree().get_nodes_in_group("computer")
	var robots = get_tree().get_nodes_in_group("robot")
	var robot_enemies = get_tree().get_nodes_in_group("robot_enemy")
	var current_scene = get_tree().get_current_scene().get_name()
	liblevel.saveAllObjects(current_scene, computers, robots, robot_enemies)

func _facing_to_vector() -> Vector2:
	match direction:
		2: return Vector2(0, 1)
		4: return Vector2(-1, 0)
		6: return Vector2(1, 0)
		8: return Vector2(0, -1)
	return Vector2.ZERO

func _on_hud_sheet_requested():
	character_sheet_instance.visible = !character_sheet_instance.visible
	if character_sheet_instance.visible:
		character_sheet_instance.refresh()

func _on_hud_setting_requested():
	if display_menu:
		display_menu = false
		background_menu.visible = false
		text_menu.visible = false
		get_tree().paused = false
		_auto_save_objects()
	else:
		display_menu = true
		background_menu.visible = true
		text_menu.visible = true
		get_tree().paused = true
		text_menu._on_button_settings_pressed()

func _on_hud_home_requested():
	display_menu = true
	background_menu.visible = true
	text_menu.visible = true
	text_menu.main.visible = true
	text_menu.settings.visible = false
	text_menu.help.visible = false
	get_tree().paused = true

func movement_sounds():
	var IS_FOOTSTEP_SOUND_PLAYING = false
	if footstep.is_playing():
		IS_FOOTSTEP_SOUND_PLAYING = true
	if !IS_FOOTSTEP_SOUND_PLAYING:
		footstep.play()

# --- Combat ---

func _update_combat_label_positions():
	var diff = global_position - combat_enemy.global_position
	var player_pos: Vector2
	var enemy_pos: Vector2

	if abs(diff.x) >= abs(diff.y):
		if diff.x < 0:
			# Joueur à gauche
			player_pos = Vector2(-120, -20)
			enemy_pos  = Vector2(40,   -20)
		else:
			# Joueur à droite
			player_pos = Vector2(40,   -20)
			enemy_pos  = Vector2(-120, -20)
	else:
		if diff.y < 0:
			# Joueur en haut
			player_pos = Vector2(-55, -90)
			enemy_pos  = Vector2(-55,  50)
		else:
			# Joueur en bas
			player_pos = Vector2(-55,  50)
			enemy_pos  = Vector2(-55, -90)

	player_combat_label.position = player_pos
	combat_enemy.combat_label.position = enemy_pos


func _start_combat(enemy):
	combat_enemy = enemy
	in_combat = true
	enemy.start_combat()
	_refresh_player_label()
	_update_combat_label_positions()

func _end_combat():
	in_combat = false
	_combat_busy = false
	if is_instance_valid(combat_enemy):
		combat_enemy.end_combat()
	player_combat_label.visible = false
	combat_enemy = null

func _end_combat_kill(dead_enemy):
	in_combat = false
	_combat_busy = false
	player_combat_label.visible = false
	combat_enemy = null
	dead_enemy.in_combat = false
	dead_enemy.die()

func _refresh_player_label():
	player_combat_label.text = "ATK:%d DEF:%d HP:%d" % [
		Player_data.player_attack,
		Player_data.player_defense,
		Player_data.player_health
	]
	player_combat_label.visible = true

func _flash_player_hit():
	var sprite = $Sprite2D
	var t1 = create_tween()
	t1.tween_property(sprite, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.08)
	t1.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	if is_instance_valid(combat_enemy):
		var knock_dir = (global_position - combat_enemy.global_position).normalized()
		var origin_pos = position
		var t2 = create_tween()
		t2.tween_property(self, "position", position + knock_dir * 6.0, 0.08)
		t2.tween_property(self, "position", origin_pos, 0.12)

func _on_attack_key():
	if not in_combat or not is_instance_valid(combat_enemy) or _combat_busy:
		return
	_combat_busy = true

	var player_roll = randi_range(10, 20)
	if player_roll <= Player_data.player_attack:
		player_combat_label.text = "ATK:%d DEF:%d HP:%d\nRoll:%d → HIT!" % [
			Player_data.player_attack, Player_data.player_defense,
			Player_data.player_health, player_roll
		]
		_resolve_robot_defense()
	else:
		player_combat_label.text = "ATK:%d DEF:%d HP:%d\nRoll:%d → MISS" % [
			Player_data.player_attack, Player_data.player_defense,
			Player_data.player_health, player_roll
		]
		_resolve_robot_attack()

	await get_tree().create_timer(0.8).timeout
	_combat_busy = false

func _attempt_flee():
	if _combat_busy:
		return
	_combat_busy = true
	# Joueur (70px/s) vs robot (35px/s) → 50% de chance de fuite
	var flee_roll = randi_range(1, 10)
	if flee_roll > 5:
		player_combat_label.text = "ATK:%d DEF:%d HP:%d\nFuite:%d → ECHAP!" % [
			Player_data.player_attack, Player_data.player_defense,
			Player_data.player_health, flee_roll
		]
		await get_tree().create_timer(0.8).timeout
		_end_combat()
	else:
		player_combat_label.text = "ATK:%d DEF:%d HP:%d\nFuite:%d → RATÉ" % [
			Player_data.player_attack, Player_data.player_defense,
			Player_data.player_health, flee_roll
		]
		if is_instance_valid(combat_enemy):
			_resolve_robot_attack()
		await get_tree().create_timer(0.8).timeout
		_combat_busy = false

func _resolve_robot_defense():
	if not is_instance_valid(combat_enemy):
		return
	var def_roll = randi_range(10, 20)
	if def_roll <= combat_enemy.enemy_defense:
		var atk_roll = randi_range(10, 20)
		var hit = atk_roll <= combat_enemy.enemy_attack
		if hit:
			Player_data.player_health -= 1
			_flash_player_hit()
			_refresh_player_label()
		combat_enemy.update_label("DEF:%d→BLK | ATK:%d→%s" % [
			def_roll, atk_roll, "HIT!" if hit else "MISS"
		])
	else:
		combat_enemy.flash_hit(global_position)
		combat_enemy.enemy_health -= 1
		if combat_enemy.enemy_health <= 0:
			combat_enemy.update_label("DEF:%d→FAIL → KO!" % def_roll)
			_end_combat_kill(combat_enemy)
		else:
			combat_enemy.update_label("DEF:%d→FAIL HP:%d" % [def_roll, combat_enemy.enemy_health])

func _resolve_robot_attack():
	if not is_instance_valid(combat_enemy):
		return
	var atk_roll = randi_range(10, 20)
	var hit = atk_roll <= combat_enemy.enemy_attack
	if hit:
		Player_data.player_health -= 1
		_flash_player_hit()
		_refresh_player_label()
	combat_enemy.update_label("ATK:%d → %s" % [atk_roll, "HIT!" if hit else "MISS"])
