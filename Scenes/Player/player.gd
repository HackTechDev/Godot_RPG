extends CharacterBody2D

var liblevel = preload("res://Lib/liblevel.gd").new()

@onready var anim_tree        = $AnimationTree
@onready var anim_state       = anim_tree.get("parameters/playback")
@onready var footstep         = $Footstep
@onready var master_sprite    = $Sprite2D
@onready var appearance_layers = $AppearanceLayers
@onready var _lyr_body        = $AppearanceLayers/SpriteBody
@onready var _lyr_legs        = $AppearanceLayers/SpriteLegs
@onready var _lyr_feet        = $AppearanceLayers/SpriteFeet
@onready var _lyr_shoulders   = $AppearanceLayers/SpriteShoulders
@onready var _lyr_torso       = $AppearanceLayers/SpriteTorso
@onready var _lyr_arms        = $AppearanceLayers/SpriteArms
@onready var _lyr_bracers     = $AppearanceLayers/SpriteBracers
@onready var _lyr_gloves      = $AppearanceLayers/SpriteGloves
@onready var _lyr_head        = $AppearanceLayers/SpriteHead
@onready var _lyr_face        = $AppearanceLayers/SpriteFace
@onready var _lyr_hair        = $AppearanceLayers/SpriteHair
@onready var _lyr_headwear    = $AppearanceLayers/SpriteHeadwear


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

var combat_ui_scene = preload("res://UI/combat_ui.tscn")
var combat_ui_instance = null

var dialogue_box_scene = preload("res://UI/dialogue_box.tscn")
var dialogue_box_instance = null

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

	combat_ui_instance = combat_ui_scene.instantiate()
	add_child(combat_ui_instance)

	dialogue_box_instance = dialogue_box_scene.instantiate()
	add_child(dialogue_box_instance)

	player_combat_label = Label.new()
	player_combat_label.position = Vector2(-55, -78)
	player_combat_label.visible = false
	player_combat_label.z_index = 10
	player_combat_label.add_theme_font_size_override("font_size", 11)
	player_combat_label.add_theme_constant_override("outline_size", 2)
	player_combat_label.add_theme_color_override("font_outline_color", Color.BLACK)
	player_combat_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	add_child(player_combat_label)

	_apply_appearance()
	_restore_sprite_state()
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
	# Sync LPC layers to the animation frame driven by AnimationPlayer
	if appearance_layers.visible:
		var f = master_sprite.frame
		for child in appearance_layers.get_children():
			if child is Sprite2D and child.visible:
				child.frame = f
	queue_redraw()

func _draw() -> void:
	if not GameConfig.debug_show_hitbox:
		return
	var spr_rect: Rect2 = master_sprite.get_rect()
	draw_rect(Rect2(master_sprite.position + spr_rect.position, spr_rect.size), Color(0.0, 0.5, 1.0, 1.0), false, 2.0)

func _input(event):
	if event.is_action_pressed("ui_pause"):
		if in_combat:
			combat_ui_instance.cancel()
			_end_combat()
			return

	if event.is_action_pressed("ui_b"):
		if GameConfig.DEBUG:
			print("b key: build")
		EventBus.build_computer.emit(direction)

	if event.is_action_pressed("ui_z"):
		if is_instance_valid(Player_data.contact_npc):
			dialogue_box_instance.open(Player_data.contact_npc.npc_name, Player_data.contact_npc.dialogue)

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
		if in_combat:
			_attempt_flee()
		elif is_instance_valid(Player_data.contact_enemy):
			_start_combat(Player_data.contact_enemy)
			_on_attack_key()

	if event.is_action_pressed("ui_a"):
		_on_attack_key()

func input_move():
	if display_menu or in_combat or (dialogue_box_instance and dialogue_box_instance.visible):
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
	if display_menu:
		display_menu = false
		background_menu.visible = false
		text_menu.visible = false
		get_tree().paused = false
		_auto_save_objects()
	character_sheet_instance.visible = !character_sheet_instance.visible
	if character_sheet_instance.visible:
		character_sheet_instance.refresh()

func _on_hud_setting_requested():
	character_sheet_instance.visible = false
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
	character_sheet_instance.visible = false
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
	combat_ui_instance.hide_ui()
	combat_enemy = null

func _end_combat_kill(dead_enemy):
	in_combat = false
	_combat_busy = false
	player_combat_label.visible = false
	combat_ui_instance.hide_ui()
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
	var flash_target: CanvasItem = appearance_layers if appearance_layers.visible else master_sprite
	var t1 = create_tween()
	t1.tween_property(flash_target, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.08)
	t1.tween_property(flash_target, "modulate", Color.WHITE, 0.15)
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
	_refresh_player_label()

	# Lancer du joueur
	var player_roll = await combat_ui_instance.prompt_player_roll("Le joueur attaque !")
	if not in_combat:
		_combat_busy = false
		return
	var attack_success = player_roll < Player_data.player_attack
	if attack_success:
		combat_ui_instance.show_result("Résultat : %d — Attaque réussie !" % player_roll, true)
	else:
		combat_ui_instance.show_result("Résultat : %d — Attaque ratée !" % player_roll, false)
	await combat_ui_instance.wait_for_continue()
	if not in_combat:
		_combat_busy = false
		return

	if not is_instance_valid(combat_enemy):
		combat_ui_instance.hide_ui()
		_combat_busy = false
		return

	if attack_success:
		await _robot_defends()
	else:
		await _robot_attacks_player()

	combat_ui_instance.hide_ui()
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
			await _robot_attacks_player()
		combat_ui_instance.hide_ui()
		_combat_busy = false

# Le robot tente de bloquer l'attaque du joueur
func _robot_defends():
	if not in_combat or not is_instance_valid(combat_enemy):
		return

	var def_roll = await combat_ui_instance.auto_roll("Le robot tente de se défendre...")
	if not in_combat:
		return
	var defense_success = def_roll < combat_enemy.enemy_defense

	if defense_success:
		combat_ui_instance.show_result("Résultat : %d — Défense réussie ! Attaque bloquée." % def_roll, true)
		combat_enemy.update_label("DEF:%d → BLK" % def_roll)
		await combat_ui_instance.wait_for_continue()
		if not in_combat:
			return
		await _robot_attacks_player()
	else:
		combat_ui_instance.show_result("Résultat : %d — Défense échouée ! Le robot perd 1 PV." % def_roll, false)
		combat_enemy.flash_hit(global_position)
		combat_enemy.enemy_health -= 1
		if combat_enemy.enemy_health <= 0:
			combat_enemy.update_label("DEF:%d → KO!" % def_roll)
			await combat_ui_instance.wait_for_continue()
			if not in_combat:
				return
			_end_combat_kill(combat_enemy)
		else:
			combat_enemy.update_label("DEF:%d → FAIL HP:%d" % [def_roll, combat_enemy.enemy_health])
			await combat_ui_instance.wait_for_continue()
			if not in_combat:
				return
			await _player_attacks_after_defense()

# Le robot attaque, le joueur tente de se défendre
func _robot_attacks_player():
	if not in_combat or not is_instance_valid(combat_enemy):
		return

	var atk_roll = await combat_ui_instance.auto_roll("Le robot attaque !")
	if not in_combat:
		return
	var robot_atk_success = atk_roll < combat_enemy.enemy_attack

	if robot_atk_success:
		combat_ui_instance.show_result("Résultat : %d — Le robot a visé !" % atk_roll, false)
	else:
		combat_ui_instance.show_result("Résultat : %d — Attaque du robot ratée !" % atk_roll, true)
	await combat_ui_instance.wait_for_continue()
	if not in_combat:
		return

	if not is_instance_valid(combat_enemy):
		return
	if not robot_atk_success:
		await _player_attacks_after_defense()
		return

	# Lancer de défense du joueur
	var def_roll = await combat_ui_instance.prompt_player_roll("Le joueur tente de se défendre...")
	if not in_combat:
		return
	var defense_success = def_roll < Player_data.player_defense

	if defense_success:
		combat_ui_instance.show_result("Résultat : %d — Défense réussie !" % def_roll, true)
		combat_enemy.update_label("ATK:%d | DEF:%d → BLK" % [atk_roll, def_roll])
		await combat_ui_instance.wait_for_continue()
		if not in_combat:
			return
		await _player_attacks_after_defense()
	else:
		combat_ui_instance.show_result("Résultat : %d — Défense échouée ! Le joueur perd 1 PV." % def_roll, false)
		Player_data.player_health -= 1
		_flash_player_hit()
		_refresh_player_label()
		if Player_data.player_health <= 0:
			combat_enemy.update_label("ATK:%d | DEF:%d → KO!" % [atk_roll, def_roll])
			_game_over_shown = true
			_end_combat()
			await combat_ui_instance.show_game_over_screen()
			_restart_game()
			return
		combat_enemy.update_label("ATK:%d | DEF:%d → HIT" % [atk_roll, def_roll])
		await combat_ui_instance.wait_for_continue()
		if not in_combat:
			return
		await _robot_attacks_player()
		return
	await combat_ui_instance.wait_for_continue()

# Le joueur contre-attaque après une défense réussie
func _player_attacks_after_defense():
	if not in_combat or not is_instance_valid(combat_enemy):
		return

	var player_roll = await combat_ui_instance.prompt_player_roll("Le joueur contre-attaque !")
	if not in_combat:
		return
	var attack_success = player_roll < Player_data.player_attack
	if attack_success:
		combat_ui_instance.show_result("Résultat : %d — Attaque réussie !" % player_roll, true)
	else:
		combat_ui_instance.show_result("Résultat : %d — Attaque ratée !" % player_roll, false)
	await combat_ui_instance.wait_for_continue()
	if not in_combat:
		return

	if not is_instance_valid(combat_enemy):
		return

	if attack_success:
		await _robot_defends()

func _apply_appearance():
	if Player_data.appearance_body == "":
		appearance_layers.visible = false
		master_sprite.visible = true
		return
	_spr_load(_lyr_body,     Player_data.appearance_body)
	_spr_load(_lyr_legs,     Player_data.appearance_legs)
	_spr_load(_lyr_feet,     Player_data.appearance_feet)
	_spr_none(_lyr_shoulders)
	_spr_load(_lyr_torso,    Player_data.appearance_torso)
	var arms = Player_data.appearance_arms
	match SpriteLibrary.get_item_layer(arms):
		"arms":    _spr_load(_lyr_arms, arms);    _spr_none(_lyr_bracers)
		"bracers": _spr_none(_lyr_arms);           _spr_load(_lyr_bracers, arms)
		_:         _spr_none(_lyr_arms);           _spr_none(_lyr_bracers)
	_spr_load(_lyr_gloves,   Player_data.appearance_hands)
	SpriteLibrary.apply_head_sprite(_lyr_head)
	SpriteLibrary.apply_face_sprite(_lyr_face)
	_spr_load(_lyr_hair,     Player_data.appearance_hair)
	_spr_load(_lyr_headwear, Player_data.appearance_headwear)
	var f = master_sprite.frame
	for child in appearance_layers.get_children():
		if child is Sprite2D:
			child.frame = f
	appearance_layers.visible = true
	master_sprite.visible = false

func _restore_sprite_state() -> void:
	var facing_vec: Vector2
	match Player_data.player_facing:
		2: facing_vec = Vector2(0, 1)
		4: facing_vec = Vector2(-1, 0)
		6: facing_vec = Vector2(1, 0)
		8: facing_vec = Vector2(0, -1)
		_: facing_vec = Vector2(0, 1)
	anim_tree.set("parameters/Idle/blend_position", facing_vec)
	anim_tree.set("parameters/Move/blend_position", facing_vec)
	master_sprite.frame = Player_data.player_sprite_frame
	for child in appearance_layers.get_children():
		if child is Sprite2D:
			child.frame = Player_data.player_sprite_frame

func _spr_load(spr: Sprite2D, key: String) -> void:
	SpriteLibrary.apply_sprite(spr, key)

func _spr_none(spr: Sprite2D) -> void:
	spr.visible = false

func _restart_game():
	liblevel.reinitializeLevel()
	Player_data.player_previous_scene = ""
	Player_data.scene_path = ""
	Player_data.player_pos_x = 0
	Player_data.player_pos_y = 0
	Player_data.player_health = Player_data.player_health_base
	Player_data.computer = 0
	Player_data.robot = 0
	Player_data.inventory = []
	Player_data.contact_object = null
	Player_data.contact_enemy = null
	liblevel.savePlayer({
		"player_position":    [Player_data_default.spawnpoint_position_x, Player_data_default.spawnpoint_position_y],
		"player_facing":      0,
		"scene":              "",
		"player_health":      Player_data.player_health,
		"player_health_base": Player_data.player_health_base,
		"player_attack":      Player_data.player_attack,
		"player_defense":     Player_data.player_defense,
		"player_nickname":    Player_data.player_nickname,
		"player_biography":   Player_data.player_biography,
		"player_rank":        Player_data.player_rank,
		"player_specialization": Player_data.player_specialization,
		"appearance_body":    Player_data.appearance_body,
		"appearance_hair":    Player_data.appearance_hair,
		"appearance_headwear": Player_data.appearance_headwear,
		"appearance_arms":    Player_data.appearance_arms,
		"appearance_hands":   Player_data.appearance_hands,
		"appearance_torso":   Player_data.appearance_torso,
		"appearance_legs":    Player_data.appearance_legs,
		"appearance_feet":    Player_data.appearance_feet,
	})
	SceneTransition.change_scene("res://UI/main_menu.tscn")
