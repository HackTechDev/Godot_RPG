class_name CameraController
extends Node2D

const LERP_SPEED: float      = 5.0
const ZOOM_LERP_SPEED: float = 3.0
const MECHA_ZOOM             := Vector2(0.8, 0.8)
const DEFAULT_ZOOM           := Vector2(1.0, 1.0)

const PAN_SPEED:        float = 300.0
const PAN_MAX:          float = 300.0
const PAN_RETURN_SPEED: float = 8.0

var follow_target: Node2D = null

var _camera: Camera2D
var _target_zoom: Vector2 = DEFAULT_ZOOM
var _pan_offset:  Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("camera_controller")
	_camera = Camera2D.new()
	add_child(_camera)
	_camera.make_current()
	_camera.zoom = DEFAULT_ZOOM
	EventBus.player_mounted_mecha.connect(_on_mounted)
	EventBus.player_dismounted_mecha.connect(_on_dismounted)

func _exit_tree() -> void:
	if EventBus.player_mounted_mecha.is_connected(_on_mounted):
		EventBus.player_mounted_mecha.disconnect(_on_mounted)
	if EventBus.player_dismounted_mecha.is_connected(_on_dismounted):
		EventBus.player_dismounted_mecha.disconnect(_on_dismounted)

func _process(delta: float) -> void:
	if not is_instance_valid(follow_target):
		return

	if Input.is_key_pressed(KEY_SHIFT):
		var pan_dir := Vector2(
			float(Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D)) -
			float(Input.is_physical_key_pressed(KEY_LEFT)  or Input.is_physical_key_pressed(KEY_A)),
			float(Input.is_physical_key_pressed(KEY_DOWN)  or Input.is_physical_key_pressed(KEY_S)) -
			float(Input.is_physical_key_pressed(KEY_UP)    or Input.is_physical_key_pressed(KEY_W))
		)
		if pan_dir != Vector2.ZERO:
			_pan_offset += pan_dir.normalized() * PAN_SPEED * delta
			_pan_offset  = _pan_offset.limit_length(PAN_MAX)
	else:
		_pan_offset = _pan_offset.lerp(Vector2.ZERO, PAN_RETURN_SPEED * delta)
		if _pan_offset.length() < 0.5:
			_pan_offset = Vector2.ZERO

	global_position = global_position.lerp(follow_target.global_position + _pan_offset, LERP_SPEED * delta)
	_camera.zoom = _camera.zoom.lerp(_target_zoom, ZOOM_LERP_SPEED * delta)

func set_follow(target: Node2D) -> void:
	follow_target = target
	if is_instance_valid(target):
		global_position = target.global_position

func _on_mounted(mecha: Node) -> void:
	set_follow(mecha as Node2D)
	_target_zoom = MECHA_ZOOM

func _on_dismounted() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		set_follow(player)
	_target_zoom = DEFAULT_ZOOM
