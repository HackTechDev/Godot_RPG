extends Node

const DEBUG = false
const _SETTINGS_PATH = "user://settings.json"

var debug_show_hitbox: bool = false
var debug_show_collision: bool = false

# Effets sonores
var sfx_enabled: bool = true
var sfx_volume_linear: float = 0.8

# Musique intro / crédits
var intro_music_enabled: bool = true

# Vitesse du joueur
var player_speed_normal: int = 70
var player_speed_slow: int = 35

# Indicateurs visuels joueur
var show_cone: bool = true

func _ready() -> void:
	if not FileAccess.file_exists(_SETTINGS_PATH):
		return
	var file := FileAccess.open(_SETTINGS_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		return
	sfx_enabled          = data.get("sfx_enabled", true)
	sfx_volume_linear    = maxf(data.get("sfx_volume_linear", 0.8), 0.01)
	intro_music_enabled  = data.get("intro_music_enabled", true)
	debug_show_hitbox    = data.get("debug_show_hitbox", false)
	debug_show_collision = data.get("debug_show_collision", false)
	show_cone            = data.get("show_cone", true)
