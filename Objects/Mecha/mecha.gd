class_name Mecha
extends CharacterBody2D

@export var mecha_id: String = ""
@export var mecha_speed: float = 120.0
@export var inertia_factor: float = 6.0
@export var proximity_range: float = 50.0
@export var hitbox_scale: float = 2.0

var is_occupied: bool = false
var facing_dir: Vector2 = Vector2.UP

var _pilot: Node2D = null
var _smooth_velocity: Vector2 = Vector2.ZERO

@onready var _hint_label:   Label              = $HintLabel
@onready var _sprite:       AnimatedSprite2D    = $AnimatedSprite2D
@onready var _col_shape:    CollisionShape2D    = $CollisionShape2D
@onready var _engine_sfx:   AudioStreamPlayer2D = $EngineSound

signal boarded(mecha: Mecha)
signal disembarked(mecha: Mecha, exit_pos: Vector2)

func _ready() -> void:
	add_to_group("mecha")
	_hint_label.visible = false
	z_index = 12

	collision_layer = 4
	collision_mask  = 1

	_rebuild_collision_shape()

	_sprite.animation = _anim_for_dir(facing_dir)
	_sprite.frame = 0
	_sprite.stop()

	if _engine_sfx.stream is AudioStreamOggVorbis:
		(_engine_sfx.stream as AudioStreamOggVorbis).loop = true


func _physics_process(delta: float) -> void:
	if not is_occupied:
		velocity = Vector2.ZERO
		_update_engine_sound(false)
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
		var anim := _anim_for_dir(facing_dir)
		if _sprite.animation != anim or not _sprite.is_playing():
			_sprite.play(anim)
	else:
		if _sprite.is_playing():
			_sprite.stop()

	_update_engine_sound(input_dir != Vector2.ZERO)
	_smooth_velocity = _smooth_velocity.lerp(input_dir * mecha_speed, inertia_factor * delta)
	velocity = _smooth_velocity
	move_and_slide()

	if is_instance_valid(_pilot):
		_pilot.global_position = global_position


func _anim_for_dir(dir: Vector2) -> StringName:
	if abs(dir.x) >= abs(dir.y):
		return &"walk_right" if dir.x >= 0 else &"walk_left"
	else:
		return &"walk_down" if dir.y > 0 else &"walk_up"


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
	_update_engine_sound(false)
	disembarked.emit(self, exit_pos)
	return exit_pos


func get_save_data() -> Dictionary:
	return {
		"id": mecha_id,
		"x": position.x,
		"y": position.y,
		"facing_x": facing_dir.x,
		"facing_y": facing_dir.y
	}


func _update_engine_sound(moving: bool) -> void:
	if not GameConfig.sfx_enabled:
		if _engine_sfx.is_playing():
			_engine_sfx.stop()
		return
	_engine_sfx.volume_db = linear_to_db(GameConfig.sfx_volume_linear)
	if moving:
		if not _engine_sfx.is_playing():
			_engine_sfx.play()
	else:
		if _engine_sfx.is_playing():
			_engine_sfx.stop()


func _rebuild_collision_shape() -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	var tex := _sprite.sprite_frames.get_frame_texture(&"walk_right", 0)
	if tex == null:
		return
	var tex_size := tex.get_size()
	var scaled   := tex_size * _sprite.scale
	var circle   := CircleShape2D.new()
	circle.radius = minf(scaled.x, scaled.y) * 0.5 * hitbox_scale
	_col_shape.shape    = circle
	_col_shape.position = Vector2.ZERO


func _find_safe_exit_position() -> Vector2:
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
	return global_position + Vector2(70, 0)
