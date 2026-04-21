extends CanvasLayer

signal sheet_requested
signal setting_requested
signal home_requested

const MAX_NIGHT_ALPHA  = 0.85   # opacité maximale de la nuit
const TRANSITION_HOURS = 1.0    # durée de la transition lever/coucher (heures de jeu)

@onready var label_nickname  = $Panel/Margin/VBox/LabelNickname
@onready var label_health    = $Panel/Margin/VBox/LabelHealth
@onready var label_computers = $Panel/Margin/VBox/LabelComputers
@onready var label_robots    = $Panel/Margin/VBox/LabelRobots
@onready var label_zone      = $Panel/Margin/VBox/LabelZone
@onready var label_position  = $Panel/Margin/VBox/LabelPosition
@onready var label_clock: Label       = $ClockAnchor/ClockPanel/LabelClock
@onready var night_overlay: ColorRect = $NightOverlay

var _tree_was_paused: bool = false
var _pause_start: float    = 0.0

func _process(_delta):
	_track_pause()
	label_nickname.text  = "Pseudo: " + Player_data.player_nickname
	label_health.text    = "Santé: " + str(Player_data.player_health)
	label_computers.text = "Ordinateurs: " + str(Player_data.computer)
	label_robots.text    = "Robots: " + str(Player_data.robot)
	label_zone.text      = "Zone: " + Player_data.player_previous_scene
	label_position.text  = "Pos: %d, %d" % [Player_data.player_pos_x, Player_data.player_pos_y]
	_update_clock()
	_update_day_night()

# Détecte les transitions pause ↔ reprise et accumule la durée gelée.
# S'exécute même quand le jeu est en pause (CanvasLayer hérite PROCESS_MODE_ALWAYS du joueur).
func _track_pause() -> void:
	if Player_data.mission_real_start <= 0.0:
		return
	var now_paused := get_tree().paused
	if now_paused and not _tree_was_paused:
		_pause_start = Time.get_unix_time_from_system()
	elif not now_paused and _tree_was_paused:
		if _pause_start > 0.0:
			Player_data.mission_paused_duration += Time.get_unix_time_from_system() - _pause_start
			_pause_start = 0.0
	_tree_was_paused = now_paused

# Temps réel écoulé depuis le début de la mission, pauses exclues.
func _elapsed_real() -> float:
	return Time.get_unix_time_from_system() - Player_data.mission_real_start - Player_data.mission_paused_duration

func _update_clock() -> void:
	if Player_data.mission_real_start <= 0.0:
		label_clock.text = "--/--/----  --h--"
		return
	var game_unix := Player_data.mission_start_unix + _elapsed_real() * 60.0
	var dt := Time.get_datetime_dict_from_unix_time(int(game_unix))
	label_clock.text = "%02d/%02d/%04d  %02dh%02d" % [dt.day, dt.month, dt.year, dt.hour, dt.minute]

func _update_day_night() -> void:
	if Player_data.mission_real_start <= 0.0:
		night_overlay.color.a = 0.0
		return
	var game_unix := Player_data.mission_start_unix + _elapsed_real() * 60.0
	var dt        := Time.get_datetime_dict_from_unix_time(int(game_unix))
	var game_hour: float = float(dt.hour) + float(dt.minute) / 60.0
	night_overlay.color.a = _compute_night_alpha(game_hour)

# Retourne l'alpha (0 = jour, MAX_NIGHT_ALPHA = nuit) selon l'heure de jeu.
# Tout est ancré sur l'heure du lever du soleil.
func _compute_night_alpha(game_hour: float) -> float:
	var rise     := Player_data.mission_sunrise_hour
	var set_h    := Player_data.mission_sunset_hour
	var since_rise := fmod(game_hour - rise + 24.0, 24.0)
	var day_len    := fmod(set_h - rise + 24.0, 24.0)

	if since_rise < TRANSITION_HOURS:
		return lerp(MAX_NIGHT_ALPHA, 0.0, since_rise / TRANSITION_HOURS)
	elif since_rise < day_len:
		return 0.0
	elif since_rise < day_len + TRANSITION_HOURS:
		return lerp(0.0, MAX_NIGHT_ALPHA, (since_rise - day_len) / TRANSITION_HOURS)
	else:
		return MAX_NIGHT_ALPHA

func _on_btn_sheet_pressed():
	sheet_requested.emit()

func _on_btn_setting_pressed():
	setting_requested.emit()

func _on_btn_home_pressed():
	home_requested.emit()
