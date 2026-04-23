class_name Mecha
extends CharacterBody2D

@export var mecha_id: String = ""
@export var mecha_speed: float = 120.0
@export var inertia_factor: float = 6.0
@export var proximity_range: float = 50.0
@export var hitbox_scale: float = 2.0
@export var rotation_speed: float = 8.0

var is_occupied: bool = false
var facing_dir: Vector2 = Vector2.UP

var _pilot: Node2D = null
var _smooth_velocity: Vector2 = Vector2.ZERO

@onready var _hint_label: Label  = $HintLabel
@onready var _sprite:     Sprite2D = $Sprite2D
@onready var _col_shape:  CollisionShape2D = $CollisionShape2D

signal boarded(mecha: Mecha)
signal disembarked(mecha: Mecha, exit_pos: Vector2)

func _ready() -> void:
	add_to_group("mecha")
	_hint_label.visible = false

	# Forcer les layers ici pour contourner les éventuels problèmes
	# de parsing du .tscn créé hors éditeur
	collision_layer = 4   # layer 3 (mecha)
	collision_mask  = 1   # détecte layer 1 (murs/TileMap)

	# Ajuster la collision shape à la taille réelle du sprite
	_rebuild_collision_shape()

func _physics_process(delta: float) -> void:
	if not is_occupied:
		velocity = Vector2.ZERO
		return

	var input_dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_LEFT)  or Input.is_physical_key_pressed(KEY_A): input_dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D): input_dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_UP)    or Input.is_physical_key_pressed(KEY_W): input_dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_DOWN)  or Input.is_physical_key_pressed(KEY_S): input_dir.y += 1.0
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()

	if input_dir != Vector2.ZERO:
		facing_dir = input_dir
	var target_angle := facing_dir.angle() + PI / 2.0
	_sprite.rotation = lerp_angle(_sprite.rotation, target_angle, rotation_speed * delta)

	_smooth_velocity = _smooth_velocity.lerp(input_dir * mecha_speed, inertia_factor * delta)
	velocity = _smooth_velocity
	move_and_slide()

	if is_instance_valid(_pilot):
		_pilot.global_position = global_position

func is_player_nearby(player_pos: Vector2) -> bool:
	return global_position.distance_to(player_pos) <= proximity_range

func show_board_hint() -> void:
	_hint_label.visible = true

func hide_board_hint() -> void:
	_hint_label.visible = false

func board(pilot: Node2D) -> void:
	is_occupied = true
	_pilot = pilot
	_smooth_velocity = Vector2.ZERO
	hide_board_hint()
	boarded.emit(self)

func disembark() -> Vector2:
	var exit_pos := _find_safe_exit_position()
	is_occupied = false
	_pilot = null
	_smooth_velocity = Vector2.ZERO
	disembarked.emit(self, exit_pos)
	return exit_pos

func get_save_data() -> Dictionary:
	return { "id": mecha_id, "x": position.x, "y": position.y }

func _rebuild_collision_shape() -> void:
	if _sprite == null or _sprite.texture == null:
		return
	var tex_size := _sprite.texture.get_size()
	var scaled   := tex_size * _sprite.scale
	var circle   := CircleShape2D.new()
	circle.radius = minf(scaled.x, scaled.y) * 0.5 * hitbox_scale
	_col_shape.shape    = circle
	_col_shape.position = Vector2.ZERO

func _find_safe_exit_position() -> Vector2:
	# Teste d'abord les directions relatives à l'orientation du mecha
	var back := -facing_dir * 70
	var left := Vector2(-facing_dir.y, facing_dir.x) * 60
	var right := -left
	var offsets: Array[Vector2] = [
		back, left, right, -back,
		back + left, back + right,
		Vector2(90, 0), Vector2(-90, 0),
		Vector2(0, 90), Vector2(0, -90),
		Vector2(80, 80), Vector2(-80, 80),
		Vector2(120, 0), Vector2(-120, 0),
	]
	var space_state := get_world_2d().direct_space_state
	for offset in offsets:
		var test_pos: Vector2 = global_position + offset
		var query := PhysicsPointQueryParameters2D.new()
		query.position = test_pos
		query.collision_mask = 1
		query.exclude = [self.get_rid()]
		if space_state.intersect_point(query).is_empty():
			return test_pos
	# Fallback : position brute sans vérification (plutôt que de rester coincé dans le mecha)
	return global_position + Vector2(70, 0)
