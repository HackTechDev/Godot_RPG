extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

const SPEED = 35.0
const DETECTION_RADIUS = 120.0
const DAMAGE_RADIUS = 30.0
const DAMAGE_COOLDOWN = 1.5

var _damage_timer = 0.0

func _ready():
	add_to_group("robot_enemy")

func _physics_process(delta):
	_damage_timer -= delta

	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
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

		if dist <= DAMAGE_RADIUS and _damage_timer <= 0.0:
			Player_data.player_health -= 1
			_damage_timer = DAMAGE_COOLDOWN
	else:
		_stand_idle()

	move_and_slide()

func _stand_idle():
	velocity = Vector2.ZERO
	anim_state.travel("Idle")
