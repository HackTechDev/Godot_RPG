extends CanvasLayer

signal sheet_requested
signal armory_requested
signal setting_requested
signal home_requested

const MAX_NIGHT_ALPHA  = 0.85
const TRANSITION_HOURS = 1.0

@onready var label_nickname  = $Panel/Margin/VBox/LabelNickname
@onready var label_health    = $Panel/Margin/VBox/LabelHealth
@onready var label_computers = $Panel/Margin/VBox/LabelComputers
@onready var label_robots    = $Panel/Margin/VBox/LabelRobots
@onready var label_zone      = $Panel/Margin/VBox/LabelZone
@onready var label_position  = $Panel/Margin/VBox/LabelPosition
@onready var label_clock: Label       = $ClockAnchor/ClockPanel/HBox/LabelClock
@onready var night_overlay: ColorRect = $NightOverlay
@onready var _hbox: HBoxContainer     = $ClockAnchor/ClockPanel/HBox

var _tree_was_paused: bool = false
var _pause_start: float    = 0.0
var _dial: Control         = null

# ─── Cadran soleil/lune ────────────────────────────────────────────────────
class _SunMoonDial extends Control:
	var hud  # non-typé : appel duck-typing sur _get_dial_data()

	func _draw() -> void:
		if hud == null:
			return
		var data: Dictionary = hud._get_dial_data()
		var cx:   float = size.x * 0.5
		var cy:   float = size.y * 0.5
		var R:    float = minf(cx, cy) - 2.0

		# Anneau de fond
		draw_arc(Vector2(cx, cy), R, 0.0, TAU, 64,
				Color(0.15, 0.15, 0.22, 0.9), 3.0, true)

		# Bande diurne (lever → coucher) en or atténué
		var rise_a: float = -PI * 0.5 + float(data.rise)  * (TAU / 24.0)
		var set_a:  float = -PI * 0.5 + float(data.set_h) * (TAU / 24.0)
		draw_arc(Vector2(cx, cy), R, rise_a, set_a, 48,
				Color(0.75, 0.6, 0.1, 0.4), 3.0, true)

		# Arc de progression minuit → heure courante
		var cur_a: float = -PI * 0.5 + float(data.hour) * (TAU / 24.0)
		var arc_col: Color
		if data.is_day:
			arc_col = Color(1.0, 0.82, 0.2, 1.0)
		else:
			arc_col = Color(0.35, 0.5, 0.95, 1.0)
		if data.active:
			draw_arc(Vector2(cx, cy), R, -PI * 0.5, cur_a, 64,
					arc_col, 3.0, true)

		# Marqueur à la position courante
		var tick: Vector2 = Vector2(cx + cos(cur_a) * R, cy + sin(cur_a) * R)
		var tick_col: Color = arc_col if bool(data.active) else Color(0.4, 0.4, 0.45, 0.6)
		draw_circle(tick, 2.5, tick_col)

		# Icône centrale
		var icon_r: float  = R * 0.38
		var center: Vector2 = Vector2(cx, cy)
		if not data.active:
			draw_circle(center, icon_r, Color(0.28, 0.28, 0.32, 0.55))
		elif data.is_day:
			# Soleil : disque jaune
			draw_circle(center, icon_r, Color(1.0, 0.88, 0.22, 1.0))
		else:
			# Lune : arc épais en croissant
			draw_arc(center, icon_r, -PI * 0.65, PI * 0.65, 32,
					Color(0.88, 0.92, 1.0, 1.0), icon_r * 0.7, true)

# ─── Initialisation ────────────────────────────────────────────────────────
func _ready() -> void:
	var dial := _SunMoonDial.new()
	dial.hud = self
	dial.custom_minimum_size = Vector2(36.0, 36.0)
	_hbox.add_child(dial)
	_hbox.move_child(dial, 0)
	_dial = dial

# ─── Boucle principale ─────────────────────────────────────────────────────
func _process(_delta: float) -> void:
	_track_pause()
	label_nickname.text  = "Pseudo: " + Player_data.player_nickname
	label_health.text    = "Santé: " + str(Player_data.player_health)
	label_computers.text = "Ordinateurs: " + str(Player_data.computer)
	label_robots.text    = "Robots: " + str(Player_data.robot)
	label_zone.text      = "Zone: " + Player_data.player_previous_scene
	label_position.text  = "Pos: %d, %d" % [Player_data.player_pos_x, Player_data.player_pos_y]
	_update_clock()
	_update_day_night()
	if _dial != null:
		_dial.queue_redraw()

# ─── Données du cadran ─────────────────────────────────────────────────────
func _get_dial_data() -> Dictionary:
	if Player_data.mission_real_start <= 0.0:
		return {
			"active": false,
			"hour":   0.0,
			"rise":   Player_data.mission_sunrise_hour,
			"set_h":  Player_data.mission_sunset_hour,
			"is_day": false
		}
	var game_unix := Player_data.mission_start_unix + _elapsed_real() * 60.0
	var dt        := Time.get_datetime_dict_from_unix_time(int(game_unix))
	var hour: float = float(dt.hour) + float(dt.minute) / 60.0
	var rise  := Player_data.mission_sunrise_hour
	var set_h := Player_data.mission_sunset_hour
	return {
		"active": true,
		"hour":   hour,
		"rise":   rise,
		"set_h":  set_h,
		"is_day": hour >= rise and hour < set_h
	}

# ─── Suivi des pauses ──────────────────────────────────────────────────────
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

func _elapsed_real() -> float:
	return Time.get_unix_time_from_system() - Player_data.mission_real_start - Player_data.mission_paused_duration

# ─── Horloge et cycle jour/nuit ────────────────────────────────────────────
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

func _compute_night_alpha(game_hour: float) -> float:
	var rise       := Player_data.mission_sunrise_hour
	var set_h      := Player_data.mission_sunset_hour
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

# ─── Boutons HUD ───────────────────────────────────────────────────────────
func _on_btn_sheet_pressed():
	sheet_requested.emit()

func _on_btn_armory_pressed():
	armory_requested.emit()

func _on_btn_setting_pressed():
	setting_requested.emit()

func _on_btn_home_pressed():
	home_requested.emit()
