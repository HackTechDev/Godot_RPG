extends Node

class_name Player_data

static var player_health = 4
static var player_health_base: int = 4
static var player_attack: int = 10
static var player_defense: int = 10
static var player_nickname: String = ""
static var player_biography: String = ""
static var player_rank: String = ""
static var player_specialization: String = ""

static var player_position = Vector2()
static var player_facing = 0

static var player_pos_x = 0
static var player_pos_y = 0

static var player_previous_scene = ""

static var spawnpoint_current = ""
static var spawnpoint_next = ""

static var player_spawnpoint_position_x = 0
static var player_spawnpoint_position_y = 0

static var save_path = "user://rpg.json"

static var scene_path = ""

static var computer = 0
static var robot = 0

static var inventory: Array = []

static var contact_object = null
static var contact_enemy = null
static var contact_npc = null

# Spawn — système LevelDoor (nom de la porte destination)
static var next_door: String = ""

# Spawn — système JSON (position absolue dans la scène destination)
static var use_json_spawn: bool = false
static var json_spawn: Vector2 = Vector2.ZERO

# Appearance (LPC spritesheet layer keys)
static var appearance_body: String = ""
static var appearance_hair: String = ""
static var appearance_headwear: String = ""
static var appearance_arms: String = ""
static var appearance_hands: String = ""
static var appearance_torso: String = ""
static var appearance_legs: String = ""
static var appearance_feet: String = ""
