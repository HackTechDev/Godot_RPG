extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

const SPEED            = 35.0
const DETECTION_RADIUS = 120.0
const CONE_FOV_HALF    = 60.0   # demi-angle du cône de vision (degrés)
const COMBAT_RADIUS    = 70.0
const DAMAGE_RADIUS    = 30.0
const DAMAGE_COOLDOWN  = 1.5

var _damage_timer  = 0.0
var facing_angle: float = -90.0  # direction du regard (degrés, 0 = droite)

var enemy_attack: int
var enemy_defense: int
var enemy_health: int
var follow_player: bool = true
var in_combat: bool = false
var _debug_label: Label = null
var _debug_cooldown: float = 0.0
var is_dead: bool = false
var death_rotation: float = 0.0
var combat_label: Label

func _ready():
	add_to_group("robot_enemy")
	enemy_attack = randi_range(10, 15)
	enemy_defense = randi_range(10, 15)
	enemy_health = randi_range(2, 3)
	_create_combat_label()
	_create_debug_label()

func _create_debug_label():
	_debug_label = Label.new()
	_debug_label.position = Vector2(-20, -100)
	_debug_label.text = "STAT"
	_debug_label.visible = false
	_debug_label.z_index = 12
	_debug_label.add_theme_font_size_override("font_size", 12)
	_debug_label.add_theme_constant_override("outline_size", 2)
	_debug_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_debug_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(_debug_label)

func _create_combat_label():
	combat_label = Label.new()
	combat_label.position = Vector2(-55, -78)
	combat_label.visible = false
	combat_label.z_index = 10
	combat_label.add_theme_font_size_override("font_size", 11)
	combat_label.add_theme_constant_override("outline_size", 2)
	combat_label.add_theme_color_override("font_outline_color", Color.BLACK)
	combat_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	add_child(combat_label)

func _physics_process(delta):
	queue_redraw()
	if _debug_label:
		_debug_label.visible = GameConfig.DEBUG and not follow_player

	# Ennemi statique : aucun déplacement possible, on court-circuite tout
	if not follow_player:
		_stand_idle()
		return

	_debug_cooldown -= delta
	if in_combat:
		_stand_idle()
		return

	_damage_timer -= delta

	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		if Player_data.contact_enemy == self:
			Player_data.contact_enemy = null
		_stand_idle()
		return

	var player    = player_nodes[0]
	var to_player = player.global_position - global_position
	var dist      = to_player.length()

	if dist <= DETECTION_RADIUS and _in_cone(to_player):
		var dir = to_player.normalized()

		if follow_player:
			if GameConfig.DEBUG and _debug_cooldown <= 0.0:
				print("[ENEMY_FOLLOW] suit le joueur dist=", int(dist), " pos=", global_position)
				_debug_cooldown = 2.0
			facing_angle = rad_to_deg(dir.angle())
			velocity = dir * SPEED
			anim_tree.set("parameters/Idle/blend_position", dir)
			anim_tree.set("parameters/Move/blend_position", dir)
			anim_state.travel("Move")
		else:
			if GameConfig.DEBUG and _debug_cooldown <= 0.0:
				print("[ENEMY_STAT] follow_player=", follow_player, " dist=", int(dist), " pos=", global_position, " → statique, idle")
				_debug_cooldown = 2.0
			_stand_idle()

		if dist <= COMBAT_RADIUS:
			Player_data.contact_enemy = self

		if dist <= DAMAGE_RADIUS:
			if _damage_timer <= 0.0:
				Player_data.player_health -= 1
				_damage_timer = DAMAGE_COOLDOWN
		elif dist > COMBAT_RADIUS:
			if Player_data.contact_enemy == self:
				Player_data.contact_enemy = null
	else:
		if Player_data.contact_enemy == self:
			Player_data.contact_enemy = null
		_stand_idle()

	move_and_slide()

func _in_cone(to_player: Vector2) -> bool:
	var facing_vec = Vector2(cos(deg_to_rad(facing_angle)), sin(deg_to_rad(facing_angle)))
	return to_player.normalized().dot(facing_vec) >= cos(deg_to_rad(CONE_FOV_HALF))

func _draw() -> void:
	if is_dead:
		return
	var look_rad  = deg_to_rad(facing_angle)
	var half_fov  = deg_to_rad(CONE_FOV_HALF)
	var steps     = 12
	var pts       = PackedVector2Array([Vector2.ZERO])
	for i in range(steps + 1):
		var a = look_rad - half_fov + 2.0 * half_fov * i / steps
		pts.append(Vector2(cos(a), sin(a)) * DETECTION_RADIUS)
	draw_colored_polygon(pts, Color(1.0, 0.15, 0.05, 0.10))
	draw_line(Vector2.ZERO, Vector2(cos(look_rad - half_fov), sin(look_rad - half_fov)) * DETECTION_RADIUS, Color(1.0, 0.15, 0.05, 0.28), 1.0)
	draw_line(Vector2.ZERO, Vector2(cos(look_rad + half_fov), sin(look_rad + half_fov)) * DETECTION_RADIUS, Color(1.0, 0.15, 0.05, 0.28), 1.0)
	if GameConfig.debug_show_collision:
		var col_pos: Vector2  = $CollisionShape2D.position
		var col_size: Vector2 = ($CollisionShape2D.shape as RectangleShape2D).size
		draw_rect(Rect2(col_pos - col_size / 2.0, col_size), Color(1, 0, 0, 0.9), false, 1.5)

func _stand_idle():
	velocity = Vector2.ZERO
	anim_state.travel("Idle")

func start_combat():
	in_combat = true
	_show_stats()

func end_combat():
	in_combat = false
	combat_label.visible = false

func _show_stats():
	combat_label.text = "ATK:%d DEF:%d HP:%d" % [enemy_attack, enemy_defense, enemy_health]
	combat_label.visible = true

func update_label(line2: String):
	combat_label.text = "ATK:%d DEF:%d HP:%d\n%s" % [enemy_attack, enemy_defense, enemy_health, line2]
	combat_label.visible = true

func flash_hit(attacker_pos: Vector2):
	var sprite = $Sprite2D
	var origin_mod = sprite.modulate
	var t1 = create_tween()
	t1.tween_property(sprite, "modulate", Color.WHITE, 0.08)
	t1.tween_property(sprite, "modulate", origin_mod, 0.15)
	var knock_dir = (global_position - attacker_pos).normalized()
	var origin_pos = position
	var t2 = create_tween()
	t2.tween_property(self, "position", position + knock_dir * 6.0, 0.08)
	t2.tween_property(self, "position", origin_pos, 0.12)

func die():
	if Player_data.contact_enemy == self:
		Player_data.contact_enemy = null
	is_dead = true
	combat_label.visible = false
	death_rotation = PI / 2.0 * (1 if randi_range(0, 1) == 0 else -1)
	$CollisionShape2D.disabled = true
	set_physics_process(false)
	velocity = Vector2.ZERO
	in_combat = false
	var tween = create_tween()
	tween.tween_property($Sprite2D, "rotation", death_rotation, 0.3)

func apply_dead_state():
	if Player_data.contact_enemy == self:
		Player_data.contact_enemy = null
	is_dead = true
	combat_label.visible = false
	$CollisionShape2D.disabled = true
	set_physics_process(false)
	velocity = Vector2.ZERO
	in_combat = false
	$Sprite2D.rotation = death_rotation
