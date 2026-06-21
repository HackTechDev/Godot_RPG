extends Node

class_name Player_data

static var player_health: int = 0
static var player_health_base: int = 0
static var player_movement: int = 50
static var player_movement_base: int = 50
static var player_attack: int = 0
static var player_defense: int = 0
static var player_stamina: int = 0
static var player_stealth: int = 0
static var player_speed: int = 0
static var player_precision: int = 0
static var player_strength: int = 0
static var player_intelligence: int = 0
static var player_weight_capacity: int = 0
static var player_credit: int = 0
static var player_equipment: Array = []
static var player_nickname: String = ""
static var player_biography: String = ""
static var player_rank: String = ""
static var player_specialization: String = ""

static var player_position = Vector2()
static var player_facing = 0

static var player_pos_x = 0
static var player_pos_y = 0

static var player_previous_scene = ""

static var player_spawnpoint_position_x = 0
static var player_spawnpoint_position_y = 0

static var save_path = "user://player.json"

static var scene_path = ""

static var computer = 0
static var robot = 0

static var inventory: Array = []

static var contact_object = null
static var contact_enemy = null
static var contact_npc = null

# Spawn — système JSON (position absolue dans la scène destination)
static var use_json_spawn: bool = false
static var json_spawn: Vector2 = Vector2.ZERO

# Frame du sprite au moment de la dernière transition
static var player_sprite_frame: int = 0

# État mecha
static var in_mecha: bool = false
static var current_mecha_id: String = ""

# Mission en cours
static var current_mission_id: String = ""

# Indique au menu principal d'ouvrir directement la création de personnage
static var goto_character_creation: bool = false

# Horloge de mission — 1 minute réelle = 1 heure de jeu
static var mission_start_unix: float = 0.0        # date/heure de début de mission (unix)
static var mission_real_start: float = 0.0        # temps réel au lancement de la mission (unix)
static var mission_paused_duration: float = 0.0   # durée cumulée des pauses (menus, dialogue…)

# Cycle jour/nuit
static var mission_sunrise_hour: float = 6.0   # heure du lever du soleil (0-24)
static var mission_sunset_hour:  float = 20.0  # heure du coucher du soleil (0-24)

# Minimap
static var minimap_enabled: bool = true
static var minimap_visited: Dictionary = {}   # Vector2i → true, remis à zéro à chaque niveau

# Appearance (LPC spritesheet layer keys)
static var appearance_body: String = ""
static var appearance_hair: String = ""
static var appearance_headwear: String = ""
static var appearance_arms: String = ""
static var appearance_hands: String = ""
static var appearance_torso: String = ""
static var appearance_legs: String = ""
static var appearance_feet: String = ""

static var movement_mode: int = 1  # 1 = marche, 2 = accroupi, 3 = course

static var player_collision_width: float    = 32.0
static var player_collision_height: float   = 50.0
static var player_collision_offset_x: float =  0.0
static var player_collision_offset_y: float =  5.0

static var character_slug: String = ""

static func set_character(slug: String) -> void:
	character_slug = slug
	save_path = "user://characters/%s/player.json" % slug if slug != "" else "user://player.json"

static func character_dir() -> String:
	return "user://characters/%s" % character_slug if character_slug != "" else "user://"

static func level_save_dir(level_name: String) -> String:
	if character_slug != "":
		return "user://characters/%s/%s" % [character_slug, level_name]
	return "user://%s" % level_name
