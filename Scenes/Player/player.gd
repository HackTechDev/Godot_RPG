extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

var speed = 70
var input_movement = Vector2.ZERO
var health = Player_data.player_health

func _ready():
	pass

func _physics_process(_delta):
	input_move()


func input_move():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_movement)
		anim_tree.set("parameters/Move/blend_position", input_movement)
		anim_state.travel("Move")
		velocity = input_movement * speed

	if input_movement == Vector2.ZERO:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO

	move_and_slide()
