extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

const SPEED = 35.0
const DETECTION_RADIUS = 120.0
const COMBAT_RADIUS = 70.0
const DAMAGE_RADIUS = 30.0
const DAMAGE_COOLDOWN = 1.5

var _damage_timer = 0.0

var enemy_attack: int
var enemy_defense: int
var enemy_health: int
var in_combat: bool = false
var is_dead: bool = false
var death_rotation: float = 0.0
var combat_label: Label

func _ready():
	add_to_group("robot_enemy")
	enemy_attack = randi_range(10, 15)
	enemy_defense = randi_range(10, 15)
	enemy_health = randi_range(2, 3)
	_create_combat_label()

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

	var player = player_nodes[0]
	var to_player = player.global_position - global_position
	var dist = to_player.length()

	if dist <= DETECTION_RADIUS:
		var dir = to_player.normalized()
		velocity = dir * SPEED
		anim_tree.set("parameters/Idle/blend_position", dir)
		anim_tree.set("parameters/Move/blend_position", dir)
		anim_state.travel("Move")

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
