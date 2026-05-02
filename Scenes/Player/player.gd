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

var armory_scene = preload("res://UI/armory.tscn")
var armory_instance = null

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

var radial_menu_scene = preload("res://UI/radial_menu.tscn")
var radial_menu_instance = null

var minimap_scene = preload("res://UI/minimap.tscn")
var minimap_instance = null

const RADIAL_CLICK_RADIUS = 26.0

var _aiming: bool        = false
var _crosshair_draw: Control = null
var _bullets: Array      = []

const _BULLET_SPEED      := 600.0
const _BULLET_MAX_TRAVEL := 2000.0
const _EXPLOSION_TEX     := preload("res://Sprites/Bullet/bullet_explosion_spritesheet.png")
const _EXPLOSION_FRAMES  := 6
const _EXPLOSION_SIZE    := 32

# ─── Viseur ────────────────────────────────────────────────────────────────
class _CrosshairDraw extends Control:
	var is_active:        bool    = false
	var player_screen:    Vector2 = Vector2.ZERO
	var has_hit:          bool    = false
	var hit_screen:       Vector2 = Vector2.ZERO
	var line_visible:     bool    = true
	var bullet_positions: Array   = []

	func _draw() -> void:
		for bp: Vector2 in bullet_positions:
			draw_rect(Rect2(bp - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), Color(0.3, 0.6, 1.0, 1.0), true)

		if not is_active:
			return
		var mpos     := get_viewport().get_mouse_position()
		var R        := 22.0
		var gap      := 6.0
		var arm      := 14.0
		var col      := Color(1.0, 0.12, 0.12, 0.95)
		var col_dark := Color(0.0, 0.0, 0.0, 0.55)

		# Ligne joueur → point d'impact (ou réticule si pas de mur)
		if line_visible:
			var line_end := hit_screen if has_hit else mpos
			draw_line(player_screen, line_end, Color(0.0, 0.0, 0.0, 0.45), 3.0)
			draw_line(player_screen, line_end, Color(1.0, 0.12, 0.12, 0.75), 1.5)

		# Réticule à la position de la souris
		draw_arc(mpos, R, 0.0, TAU, 48, col_dark, 4.0, true)
		draw_arc(mpos, R, 0.0, TAU, 48, col,      2.0, true)
		draw_circle(mpos, 2.0, col)
		for off: Vector2 in [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]:
			var p0 := mpos + off * (R + gap)
			var p1 := mpos + off * (R + gap + arm)
			draw_line(p0, p1, col_dark, 4.0)
			draw_line(p0, p1, col,      2.0)

func _radial_items() -> Array:
	return [
		{"id": "build",   "letter": "B", "label": "Construire", "disabled": false},
		{"id": "take",    "letter": "T", "label": "Ramasser",   "disabled": not is_instance_valid(Player_data.contact_object)},
		{"id": "talk",    "letter": "Z", "label": "Parler",     "disabled": not is_instance_valid(Player_data.contact_npc)},
		{"id": "combat",  "letter": "C", "label": "Combat",     "disabled": not is_instance_valid(Player_data.contact_enemy)},
		{"id": "sheet",   "letter": "P", "label": "Fiche",      "disabled": false},
		{"id": "attack",  "letter": "A", "label": "Attaquer",   "disabled": false},
		{"id": "minimap", "letter": "M", "label": "Carte",      "disabled": false},
		{"id": "shoot",   "letter": "F", "label": "Tirer",      "disabled": false},
	]

const CONE_LENGTH   = 130.0
const CONE_FOV_HALF = 45.0   # demi-angle du cône (degrés)

var speed = 70
var input_movement = Vector2.ZERO
var health = Player_data.player_health

# --- Mecha ---
var _in_mecha: bool = false
var _active_mecha: Mecha = null
var _nearby_mecha: Mecha = null
var _mecha_cooldown: float = 0.0
const MECHA_COOLDOWN_TIME: float = 1.0
const MECHA_PROXIMITY: float = 50.0

# Angles en degrés : 0 = droite, 90 = bas, 180 = gauche, -90 = haut
var body_angle: float = -90.0   # direction du corps (pavé 4/6)
var look_angle: float = -90.0   # direction du regard/cône (pavé 7/9)
var _debug_speed: float = 0.0

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
	background_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in background_menu.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_menu = menu_instance.get_node("MainMenuLayer")
	text_menu.visible = false

	play_button_menu = menu_instance.get_node("MainMenuLayer/Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonPlay")
	play_button_menu.text = "Retour à la mission"
	play_button_menu.pressed.disconnect(text_menu._on_button_play_pressed)
	play_button_menu.pressed.connect(_close_menu)
	text_menu.set_in_game_mode(true)
	text_menu.return_to_game.connect(_close_menu)

	character_sheet_instance = character_sheet_scene.instantiate()
	add_child(character_sheet_instance)
	character_sheet_instance.appearance_changed.connect(_on_cs_appearance_changed)

	armory_instance = armory_scene.instantiate()
	add_child(armory_instance)
	armory_instance.item_purchased.connect(_on_armory_item_purchased)

	hud_instance = hud_scene.instantiate()
	add_child(hud_instance)
	hud_instance.sheet_requested.connect(_on_hud_sheet_requested)
	hud_instance.armory_requested.connect(_on_hud_armory_requested)
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

	radial_menu_instance = radial_menu_scene.instantiate()
	add_child(radial_menu_instance)
	radial_menu_instance.action_selected.connect(_handle_radial_action)
	radial_menu_instance.closed.connect(func():
		get_tree().paused = false
		if _aiming:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	)

	minimap_instance = minimap_scene.instantiate()
	add_child(minimap_instance)

	_setup_crosshair()

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
	# Désactive la caméra embarquée si CameraController gère la caméra
	call_deferred("_disable_own_camera_if_controller")
	SceneTransition.fade_in()
	Performance.add_custom_monitor("Joueur/regard_angle",  func(): return look_angle)
	Performance.add_custom_monitor("Joueur/corps_angle",   func(): return body_angle)
	Performance.add_custom_monitor("Joueur/vitesse",       func(): return _debug_speed)

func _exit_tree():
	if _aiming:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Performance.remove_custom_monitor("Joueur/regard_angle")
	Performance.remove_custom_monitor("Joueur/corps_angle")
	Performance.remove_custom_monitor("Joueur/vitesse")

func _physics_process(delta: float) -> void:
	if _mecha_cooldown > 0.0:
		_mecha_cooldown -= delta
	input_move()

func _process(_delta: float):
	if not _in_mecha:
		_update_nearby_mecha()
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
	if _aiming and _crosshair_draw != null:
		_update_aim_line()
		_crosshair_draw.queue_redraw()
	_update_bullets(_delta)

func _draw() -> void:
	if GameConfig.debug_show_hitbox:
		var spr_rect: Rect2 = master_sprite.get_rect()
		draw_rect(Rect2(master_sprite.position + spr_rect.position, spr_rect.size), Color(0.0, 0.5, 1.0, 1.0), false, 2.0)

	if GameConfig.show_cone:
		# --- Cône de vision ---
		var look_rad  = deg_to_rad(look_angle)
		var half_fov  = deg_to_rad(CONE_FOV_HALF)
		var steps     = 12
		var pts       = PackedVector2Array([Vector2.ZERO])
		for i in range(steps + 1):
			var a = look_rad - half_fov + 2.0 * half_fov * i / steps
			pts.append(Vector2(cos(a), sin(a)) * CONE_LENGTH)
		draw_colored_polygon(pts, Color(0.2, 1.0, 0.3, 0.12))
		draw_line(Vector2.ZERO, Vector2(cos(look_rad - half_fov), sin(look_rad - half_fov)) * CONE_LENGTH, Color(0.2, 1.0, 0.3, 0.35), 1.0)
		draw_line(Vector2.ZERO, Vector2(cos(look_rad + half_fov), sin(look_rad + half_fov)) * CONE_LENGTH, Color(0.2, 1.0, 0.3, 0.35), 1.0)

		# --- Flèche de direction du corps ---
		var body_rad  = deg_to_rad(body_angle)
		var body_dir_vec  = Vector2(cos(body_rad), sin(body_rad))
		var perp      = Vector2(-sin(body_rad), cos(body_rad))
		var tip       = body_dir_vec * 28.0
		var base      = tip - body_dir_vec * 10.0
		draw_line(Vector2.ZERO, tip, Color(1.0, 0.55, 0.0, 0.85), 2.0)
		draw_colored_polygon(
			PackedVector2Array([tip, base + perp * 5.0, base - perp * 5.0]),
			Color(1.0, 0.55, 0.0, 0.85)
		)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var screen_pos = get_global_transform_with_canvas().origin
		if event.position.distance_to(screen_pos) <= RADIAL_CLICK_RADIUS:
			if radial_menu_instance.visible:
				radial_menu_instance._close()
				get_viewport().set_input_as_handled()
			elif not display_menu and not in_combat \
					and not (dialogue_box_instance and dialogue_box_instance.visible):
				if _aiming:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				radial_menu_instance.show_at(screen_pos, _radial_items())
				get_tree().paused = true
				get_viewport().set_input_as_handled()
			return

	if _aiming and event.is_action_pressed("ui_space"):
		if _crosshair_draw != null and _crosshair_draw.line_visible:
			_fire_bullet()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_pause"):
		if radial_menu_instance and radial_menu_instance.visible:
			radial_menu_instance._close()
			return
		if in_combat:
			combat_ui_instance.cancel()
			_end_combat()
			return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_KP_4: _rotate_body(-45.0)
			KEY_KP_6: _rotate_body(45.0)
			KEY_KP_7: _rotate_look(-45.0)
			KEY_KP_9: _rotate_look(45.0)
			KEY_1: Player_data.movement_mode = 1
			KEY_2: Player_data.movement_mode = 2
			KEY_3: Player_data.movement_mode = 3

	if event.is_action_pressed("ui_m"):
		if not display_menu and not in_combat \
				and not (dialogue_box_instance and dialogue_box_instance.visible):
			_on_mecha_key()

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
	if _in_mecha:
		return
	if display_menu or in_combat \
			or (dialogue_box_instance and dialogue_box_instance.visible):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Mouvement via touches fléchées / WASD uniquement (exclut le pavé numérique)
	input_movement = Vector2.ZERO
	if Input.is_key_pressed(KEY_SHIFT):
		return
	if Input.is_physical_key_pressed(KEY_LEFT)  or Input.is_physical_key_pressed(KEY_A): input_movement.x -= 1.0
	if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D): input_movement.x += 1.0
	if Input.is_physical_key_pressed(KEY_UP)    or Input.is_physical_key_pressed(KEY_W): input_movement.y -= 1.0
	if Input.is_physical_key_pressed(KEY_DOWN)  or Input.is_physical_key_pressed(KEY_S): input_movement.y += 1.0
	if input_movement.length() > 1.0:
		input_movement = input_movement.normalized()

	# L'animation suit toujours la direction du regard
	var look_vec = _angle_to_vec(look_angle)
	# Vitesse réduite si : corps ≠ regard, OU si le joueur recule par rapport au corps
	var aligned        = abs(_norm_angle(look_angle - body_angle)) < 1.0
	var moving_forward = input_movement.dot(_angle_to_vec(body_angle)) > 1e-6
	var current_speed: float
	match Player_data.movement_mode:
		2: current_speed = 20.0
		3: current_speed = 130.0 if (aligned and moving_forward) else 55.0
		_: current_speed = GameConfig.player_speed_normal if (aligned and moving_forward) else GameConfig.player_speed_slow

	_debug_speed = current_speed
	if input_movement != Vector2.ZERO:
		movement_sounds()
		anim_tree.set("parameters/Idle/blend_position", look_vec)
		anim_tree.set("parameters/Move/blend_position", look_vec)
		anim_state.travel("Move")
		velocity = input_movement * current_speed
	else:
		if footstep.is_playing():
			footstep.stop()
		anim_tree.set("parameters/Idle/blend_position", look_vec)
		anim_state.travel("Idle")
		velocity = Vector2.ZERO

	direction = _angle_to_dir4(body_angle)
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
	var mechas = get_tree().get_nodes_in_group("mecha")
	var current_scene = get_tree().get_current_scene().get_name()
	liblevel.saveAllObjects(current_scene, computers, robots, robot_enemies, mechas)

func _auto_save_player():
	liblevel.savePlayer({
		"player_position":        [Player_data.player_pos_x, Player_data.player_pos_y],
		"player_facing":          Player_data.player_facing,
		"scene":                  Player_data.player_previous_scene,
		"player_health":          Player_data.player_health,
		"player_health_base":     Player_data.player_health_base,
		"player_attack":          Player_data.player_attack,
		"player_defense":         Player_data.player_defense,
		"player_stamina":         Player_data.player_stamina,
		"player_stealth":         Player_data.player_stealth,
		"player_speed":           Player_data.player_speed,
		"player_precision":       Player_data.player_precision,
		"player_strength":        Player_data.player_strength,
		"player_intelligence":    Player_data.player_intelligence,
		"player_weight_capacity": Player_data.player_weight_capacity,
		"player_credit":          Player_data.player_credit,
		"player_equipment":       Player_data.player_equipment,
		"player_nickname":        Player_data.player_nickname,
		"player_biography":       Player_data.player_biography,
		"player_rank":            Player_data.player_rank,
		"player_specialization":  Player_data.player_specialization,
		"appearance_body":        Player_data.appearance_body,
		"appearance_hair":        Player_data.appearance_hair,
		"appearance_headwear":    Player_data.appearance_headwear,
		"appearance_arms":        Player_data.appearance_arms,
		"appearance_hands":       Player_data.appearance_hands,
		"appearance_torso":       Player_data.appearance_torso,
		"appearance_legs":        Player_data.appearance_legs,
		"appearance_feet":        Player_data.appearance_feet,
	})

func _on_armory_item_purchased() -> void:
	_auto_save_player()

func _facing_to_vector() -> Vector2:
	match direction:
		2: return Vector2(0, 1)
		4: return Vector2(-1, 0)
		6: return Vector2(1, 0)
		8: return Vector2(0, -1)
	return Vector2.ZERO

func _on_cs_appearance_changed() -> void:
	_apply_appearance()
	_auto_save_player()

func _on_hud_sheet_requested():
	if display_menu:
		display_menu = false
		background_menu.visible = false
		text_menu.visible = false
		_auto_save_objects()
	armory_instance.visible = false
	character_sheet_instance.visible = !character_sheet_instance.visible
	if character_sheet_instance.visible:
		character_sheet_instance.refresh()
		get_tree().paused = true
	else:
		get_tree().paused = false

func _on_hud_armory_requested():
	if display_menu:
		display_menu = false
		background_menu.visible = false
		text_menu.visible = false
		_auto_save_objects()
	character_sheet_instance.visible = false
	armory_instance.visible = !armory_instance.visible
	get_tree().paused = armory_instance.visible

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
	text_menu.show_main_panel()
	get_tree().paused = true

func movement_sounds():
	if not GameConfig.sfx_enabled:
		if footstep.is_playing():
			footstep.stop()
		return
	footstep.volume_db = linear_to_db(GameConfig.sfx_volume_linear)
	if not footstep.is_playing():
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
	body_angle = _dir_to_angle(Player_data.player_facing)
	look_angle = body_angle
	var look_vec = _angle_to_vec(look_angle)
	anim_tree.set("parameters/Idle/blend_position", look_vec)
	anim_tree.set("parameters/Move/blend_position", look_vec)
	master_sprite.frame = Player_data.player_sprite_frame
	for child in appearance_layers.get_children():
		if child is Sprite2D:
			child.frame = Player_data.player_sprite_frame

# --- Helpers angle / direction ---

func _norm_angle(a: float) -> float:
	a = fmod(a, 360.0)
	if a > 180.0:   a -= 360.0
	elif a <= -180.0: a += 360.0
	return a

func _dir_to_angle(dir: int) -> float:
	match dir:
		2: return 90.0
		4: return 180.0
		6: return 0.0
		8: return -90.0
		_: return -90.0

func _angle_to_dir4(angle_deg: float) -> int:
	var a = _norm_angle(angle_deg)
	if a > -45.0  and a <= 45.0:  return 6  # droite
	if a > 45.0   and a <= 135.0: return 2  # bas
	if a > -135.0 and a <= -45.0: return 8  # haut
	return 4                                 # gauche

func _angle_to_vec(angle_deg: float) -> Vector2:
	var r = deg_to_rad(angle_deg)
	return Vector2(cos(r), sin(r))

func _rotate_body(delta: float) -> void:
	body_angle = _norm_angle(body_angle + delta)
	# Si le regard devient opposé au corps, on le ramène sur le corps
	if abs(_norm_angle(look_angle - body_angle)) > 45.0:
		look_angle = body_angle

func _rotate_look(delta: float) -> void:
	var new_angle = _norm_angle(look_angle + delta)
	# Le cône ne peut pas dépasser ±90° par rapport au corps
	if abs(_norm_angle(new_angle - body_angle)) > 45.0:
		return
	look_angle = new_angle

func _spr_load(spr: Sprite2D, key: String) -> void:
	SpriteLibrary.apply_sprite(spr, key)

func _spr_none(spr: Sprite2D) -> void:
	spr.visible = false

# --- Mecha ---

func _disable_own_camera_if_controller() -> void:
	if get_tree().get_first_node_in_group("camera_controller") != null:
		var cam := get_node_or_null("Camera2D") as Camera2D
		if cam:
			cam.enabled = false

func _update_nearby_mecha() -> void:
	var best: Mecha = null
	var best_dist := INF
	for node in get_tree().get_nodes_in_group("mecha"):
		var m := node as Mecha
		if m == null or m.is_occupied:
			continue
		var d := global_position.distance_to(m.global_position)
		if d < best_dist:
			best_dist = d
			best = m
	# Masquer l'ancien hint si la cible change
	if is_instance_valid(_nearby_mecha) and _nearby_mecha != best:
		_nearby_mecha.hide_board_hint()
	_nearby_mecha = best
	if is_instance_valid(_nearby_mecha) and _nearby_mecha.is_player_nearby(global_position):
		_nearby_mecha.show_board_hint()
	elif is_instance_valid(_nearby_mecha):
		_nearby_mecha.hide_board_hint()
		_nearby_mecha = null

func _on_mecha_key() -> void:
	if _mecha_cooldown > 0.0:
		return
	if _in_mecha:
		_dismount_mecha()
	elif is_instance_valid(_nearby_mecha) and _nearby_mecha.is_player_nearby(global_position):
		_mount_mecha(_nearby_mecha)

func _mount_mecha(mecha: Mecha) -> void:
	_in_mecha = true
	_active_mecha = mecha
	_mecha_cooldown = MECHA_COOLDOWN_TIME
	Player_data.in_mecha = true
	Player_data.current_mecha_id = mecha.mecha_id
	master_sprite.visible = false
	appearance_layers.visible = false
	# Désactiver la collision du joueur (évite l'interférence avec les murs)
	var col := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col:
		col.set_deferred("disabled", true)
	velocity = Vector2.ZERO
	mecha.board(self)
	EventBus.player_mounted_mecha.emit(mecha)

func _dismount_mecha() -> void:
	if not is_instance_valid(_active_mecha):
		_in_mecha = false
		Player_data.in_mecha = false
		return
	var exit_pos := _active_mecha.disembark()
	global_position = exit_pos
	_in_mecha = false
	_mecha_cooldown = MECHA_COOLDOWN_TIME
	Player_data.in_mecha = false
	Player_data.current_mecha_id = ""
	_active_mecha = null
	# Réactiver collision
	var col := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col:
		col.set_deferred("disabled", false)
	# Restaurer sprite
	_apply_appearance()
	EventBus.player_dismounted_mecha.emit()

func force_dismount() -> void:
	if _in_mecha:
		_dismount_mecha()

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
		"player_position":        [Player_data_default.spawnpoint_position_x, Player_data_default.spawnpoint_position_y],
		"player_facing":          0,
		"scene":                  "",
		"player_health":          Player_data.player_health,
		"player_health_base":     Player_data.player_health_base,
		"player_attack":          Player_data.player_attack,
		"player_defense":         Player_data.player_defense,
		"player_stamina":         Player_data.player_stamina,
		"player_stealth":         Player_data.player_stealth,
		"player_speed":           Player_data.player_speed,
		"player_precision":       Player_data.player_precision,
		"player_strength":        Player_data.player_strength,
		"player_intelligence":    Player_data.player_intelligence,
		"player_weight_capacity": Player_data.player_weight_capacity,
		"player_credit":          Player_data.player_credit,
		"player_equipment":       Player_data.player_equipment,
		"player_nickname":        Player_data.player_nickname,
		"player_biography":       Player_data.player_biography,
		"player_rank":            Player_data.player_rank,
		"player_specialization":  Player_data.player_specialization,
		"appearance_body":        Player_data.appearance_body,
		"appearance_hair":        Player_data.appearance_hair,
		"appearance_headwear":    Player_data.appearance_headwear,
		"appearance_arms":        Player_data.appearance_arms,
		"appearance_hands":       Player_data.appearance_hands,
		"appearance_torso":       Player_data.appearance_torso,
		"appearance_legs":        Player_data.appearance_legs,
		"appearance_feet":        Player_data.appearance_feet,
	})
	SceneTransition.change_scene("res://UI/main_menu.tscn")

func _handle_radial_action(action_id: String) -> void:
	match action_id:
		"build":
			EventBus.build_computer.emit(direction)
		"take":
			if is_instance_valid(Player_data.contact_object):
				Player_data.contact_object.collect()
		"talk":
			if is_instance_valid(Player_data.contact_npc):
				dialogue_box_instance.open(Player_data.contact_npc.npc_name, Player_data.contact_npc.dialogue)
		"combat":
			if is_instance_valid(Player_data.contact_enemy):
				_start_combat(Player_data.contact_enemy)
				_on_attack_key()
		"sheet":
			character_sheet_instance.visible = not character_sheet_instance.visible
			if character_sheet_instance.visible:
				character_sheet_instance.refresh()
		"attack":
			_on_attack_key()
		"minimap":
			if minimap_instance != null:
				minimap_instance.toggle()
		"shoot":
			_toggle_aiming()

# ─── Viseur ────────────────────────────────────────────────────────────────
func _update_aim_line() -> void:
	var canvas_xform := get_viewport().get_canvas_transform()
	_crosshair_draw.player_screen = canvas_xform * global_position

	var mpos_screen := get_viewport().get_mouse_position()
	var mouse_world := canvas_xform.affine_inverse() * mpos_screen

	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, mouse_world, 1)
	query.exclude = [get_rid()]
	var hit := space_state.intersect_ray(query)

	if hit.is_empty():
		_crosshair_draw.has_hit = false
	else:
		_crosshair_draw.has_hit = true
		_crosshair_draw.hit_screen = canvas_xform * hit["position"]

	var dir_to_mouse := mouse_world - global_position
	var angle_to_mouse := rad_to_deg(atan2(dir_to_mouse.y, dir_to_mouse.x))
	var diff := fmod(angle_to_mouse - look_angle + 540.0, 360.0) - 180.0
	_crosshair_draw.line_visible = absf(diff) <= CONE_FOV_HALF

func _setup_crosshair() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 15
	add_child(cl)
	var dc := _CrosshairDraw.new()
	dc.set_anchors_preset(Control.PRESET_FULL_RECT)
	dc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(dc)
	_crosshair_draw = dc

func _toggle_aiming() -> void:
	_aiming = not _aiming
	if _crosshair_draw != null:
		_crosshair_draw.is_active = _aiming
		_crosshair_draw.queue_redraw()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if _aiming else Input.MOUSE_MODE_VISIBLE)
	_set_hud_topbar_interactive(not _aiming)

func _set_hud_topbar_interactive(enabled: bool) -> void:
	if hud_instance == null:
		return
	var hbox: Node = hud_instance.get_node_or_null("TopBar/HBox")
	if hbox == null:
		return
	for child in hbox.get_children():
		if child is Button:
			child.disabled = not enabled

func _update_bullets(delta: float) -> void:
	if _crosshair_draw != null:
		_crosshair_draw.bullet_positions.clear()
	var space_state := get_world_2d().direct_space_state
	for b in _bullets.duplicate():
		b["traveled"] += _BULLET_SPEED * delta
		if b["traveled"] > _BULLET_MAX_TRAVEL:
			_bullets.erase(b)
			continue
		var prev: Vector2 = b["pos"]
		var next: Vector2 = prev + (b["dir"] as Vector2) * _BULLET_SPEED * delta
		var query := PhysicsRayQueryParameters2D.create(prev, next)
		query.exclude = [get_rid()]
		var hit := space_state.intersect_ray(query)
		if not hit.is_empty():
			_bullets.erase(b)
			_spawn_explosion(hit["position"])
			continue
		b["pos"] = next
		if _crosshair_draw != null:
			var screen_pos: Vector2 = get_viewport().get_canvas_transform() * next
			_crosshair_draw.bullet_positions.append(screen_pos)
	if _crosshair_draw != null:
		_crosshair_draw.queue_redraw()

func _spawn_explosion(world_pos: Vector2) -> void:
	var frames := SpriteFrames.new()
	frames.add_animation("exp")
	frames.set_animation_loop("exp", false)
	frames.set_animation_speed("exp", 12.0)
	for i in _EXPLOSION_FRAMES:
		var at := AtlasTexture.new()
		at.atlas  = _EXPLOSION_TEX
		at.region = Rect2(i * _EXPLOSION_SIZE, 0, _EXPLOSION_SIZE, _EXPLOSION_SIZE)
		frames.add_frame("exp", at)
	var anim := AnimatedSprite2D.new()
	anim.sprite_frames  = frames
	anim.animation      = "exp"
	anim.z_index        = 100
	anim.global_position = world_pos
	get_parent().add_child(anim)
	anim.play()
	anim.animation_finished.connect(anim.queue_free)

func _fire_bullet() -> void:
	var canvas_xform := get_viewport().get_canvas_transform()
	var mouse_world  := canvas_xform.affine_inverse() * get_viewport().get_mouse_position()
	var dir          := (mouse_world - global_position).normalized()
	_bullets.append({"pos": global_position, "dir": dir, "traveled": 0.0})
