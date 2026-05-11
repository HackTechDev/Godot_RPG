extends CanvasLayer

signal return_to_game

const SETTINGS_PATH = "user://settings.json"
const TOTAL_POINTS = 60

var liblevel = preload("res://Lib/liblevel.gd").new()

var _in_game: bool = false

@onready var main: Control = $Main
@onready var settings: Control = $Settings
@onready var help: Control = $Help
@onready var audio_settings: Control = $AudioSettings
@onready var controls_settings: Control = $ControlsSettings
@onready var character_creation: Control = $CharacterCreation
@onready var check_music: CheckButton = $AudioSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckMusic
@onready var slider_volume: HSlider = $AudioSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SliderVolume
@onready var check_sfx: CheckButton = $AudioSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckSfx
@onready var slider_sfx_volume: HSlider = $AudioSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SliderSfxVolume
@onready var check_intro_music: CheckButton = $AudioSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckIntroMusic
@onready var mission_select: Control = $MissionSelect
@onready var debug_settings: Control = $DebugSettings
@onready var video_settings: Control = $VideoSettings
@onready var check_fullscreen: CheckButton = $VideoSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckFullscreen
@onready var check_debug_hitbox: CheckButton = $DebugSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckDebugHitbox
@onready var check_debug_collision: CheckButton = $DebugSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckDebugCollision
@onready var check_show_cone: CheckButton     = $DebugSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckShowCone
@onready var check_show_aim_line: CheckButton = $DebugSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckShowAimLine
@onready var quit_dialog: ConfirmationDialog = $QuitDialog
@onready var _btn_settings_back: Button = $Settings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonSettingsBack

const _MS_BASE = "MissionSelect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer"
@onready var ms_list:        ItemList      = get_node(_MS_BASE + "/MissionList")
@onready var ms_title:       Label         = get_node(_MS_BASE + "/LabelMissionTitle")
@onready var ms_datetime:    Label         = get_node(_MS_BASE + "/LabelDatetime")
@onready var ms_description: RichTextLabel = get_node(_MS_BASE + "/TextDescription")
@onready var ms_objectives:  RichTextLabel = get_node(_MS_BASE + "/TextObjectives")
@onready var ms_btn_accept:  Button        = get_node(_MS_BASE + "/ButtonsRow/ButtonAccept")

var _missions: Array = []
var _selected_mission: Dictionary = {}

var _mr_panel:          Control        = null
var _mr_title:          Label          = null
var _mr_datetime:       Label          = null
var _mr_game_datetime:  Label          = null
var _mr_elapsed:        Label          = null
var _mr_health:         Label          = null
var _mr_objectives:     RichTextLabel  = null

var _cs_panel:         Control  = null
var _cs_list:          ItemList = null
var _cs_btn_play:      Button   = null
var _cs_empty_label:   Label    = null
var _cs_selected_slug: String   = ""
var _cs_characters:    Array    = []
var _cc_from_cs:       bool     = false

var _cm_panel:         Control            = null
var _cm_rows_vbox:     VBoxContainer      = null
var _cm_delete_dialog: ConfirmationDialog = null
var _cm_delete_slug:   String             = ""
var _cm_party_vbox:    VBoxContainer      = null   # section équipe dans le panel

@onready var music_neon_dream: AudioStreamPlayer = $"../Music_Neon_Dream"

const _CC_BASE = "CharacterCreation/CenterContainer/PanelContainer/MarginContainer/VBoxContainer"
const _CC_PA   = _CC_BASE + "/PageAppearance/ContentRow"

@onready var cc_page_identity:   VBoxContainer = get_node(_CC_BASE + "/PageIdentity")
@onready var cc_page_appearance: VBoxContainer = get_node(_CC_BASE + "/PageAppearance")
@onready var cc_page_military:   VBoxContainer = get_node(_CC_BASE + "/PageMilitary")
@onready var cc_page_stats:      VBoxContainer = get_node(_CC_BASE + "/PageStats")

@onready var cc_btn_back:   Button = get_node(_CC_BASE + "/ButtonsRowShared/BackButton")
@onready var cc_btn_next:   Button = get_node(_CC_BASE + "/ButtonsRowShared/NextButton")
@onready var cc_btn_create: Button = get_node(_CC_BASE + "/ButtonsRowShared/CreateButton")

var _cc_current_page: int = 1

@onready var cc_nickname:  LineEdit      = get_node(_CC_BASE + "/PageIdentity/NicknameEdit")
@onready var cc_biography: TextEdit      = get_node(_CC_BASE + "/PageIdentity/BiographyEdit")
@onready var cc_rank:      OptionButton  = get_node(_CC_BASE + "/PageMilitary/RankOption")
@onready var cc_spec_list: ItemList      = get_node(_CC_BASE + "/PageMilitary/SpecRow/SpecList")
@onready var cc_spec_desc: RichTextLabel = get_node(_CC_BASE + "/PageMilitary/SpecRow/SpecDescPanel/SpecDescMargin/SpecDesc")
@onready var cc_health:       SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/HealthRow/HealthSpinBox")
@onready var cc_attack:       SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/AttackRow/AttackSpinBox")
@onready var cc_defense:      SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/DefenseRow/DefenseSpinBox")
@onready var cc_stamina:      SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/StaminaRow/StaminaSpinBox")
@onready var cc_stealth:      SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/StealthRow/StealthSpinBox")
@onready var cc_speed:        SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/SpeedRow/SpeedSpinBox")
@onready var cc_precision:    SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/PrecisionRow/PrecisionSpinBox")
@onready var cc_strength:     SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/StrengthRow/StrengthSpinBox")
@onready var cc_intelligence: SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/IntelligenceRow/IntelligenceSpinBox")
@onready var cc_weight:       SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/WeightRow/WeightSpinBox")
@onready var cc_movement:     SpinBox = get_node(_CC_BASE + "/PageStats/StatsContainer/MovementRow/MovementSpinBox")
@onready var cc_remaining:    Label   = get_node(_CC_BASE + "/PageStats/LabelRemaining")

# Appearance page option buttons
@onready var cc_body_opt:     OptionButton = get_node(_CC_PA + "/OptionsScroll/OptionsVBox/BodyOption")
@onready var cc_hair_opt:     OptionButton = get_node(_CC_PA + "/OptionsScroll/OptionsVBox/HairOption")
@onready var cc_headwear_opt: OptionButton = get_node(_CC_PA + "/OptionsScroll/OptionsVBox/HeadwearOption")
@onready var cc_arms_opt:     OptionButton = get_node(_CC_PA + "/OptionsScroll/OptionsVBox/ArmsOption")
@onready var cc_hands_opt:    OptionButton = get_node(_CC_PA + "/OptionsScroll/OptionsVBox/HandsOption")
@onready var cc_torso_opt:    OptionButton = get_node(_CC_PA + "/OptionsScroll/OptionsVBox/TorsoOption")
@onready var cc_legs_opt:     OptionButton = get_node(_CC_PA + "/OptionsScroll/OptionsVBox/LegsOption")
@onready var cc_feet_opt:     OptionButton = get_node(_CC_PA + "/OptionsScroll/OptionsVBox/FeetOption")

# Appearance preview sprites
@onready var cc_spr_body:     Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteBody")
@onready var cc_spr_legs:     Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteLegs")
@onready var cc_spr_feet:     Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteFeet")
@onready var cc_spr_shoulders:Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteShoulders")
@onready var cc_spr_torso:    Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteTorso")
@onready var cc_spr_arms:     Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteArms")
@onready var cc_spr_bracers:  Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteBracers")
@onready var cc_spr_gloves:   Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteGloves")
@onready var cc_spr_head:     Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteHead")
@onready var cc_spr_face:     Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteFace")
@onready var cc_spr_hair:     Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteHair")
@onready var cc_spr_headwear: Sprite2D = get_node(_CC_PA + "/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport/SpriteHeadwear")


const CC_RANKS: Array = [
	"Militaires du rang",
	"Sous-officiers",
	"Officiers",
	"Officiers généraux (haut commandement)"
]

const CC_SPECS: Dictionary = {
	"Opérateur FS": "[b]Opérateur Forces Spéciales[/b] (combat / action directe)\n\n[ul]Combat rapproché, assaut, capture d'objectifs\nInfiltration (parachute, hélico, terrestre…)\nReconnaissance offensive\nAppui aux autres spécialistes[/ul]",
	"Tireur de précision": "[b]Tireur de précision[/b] (sniper / TP)\n\n[ul]Observation longue distance\nNeutralisation de cibles sensibles\nRenseignement discret\nCouverture des équipes[/ul]",
	"Transmetteur": "[b]Transmetteur[/b] (spécialiste communications)\n\n[ul]Gestion des radios et communications sécurisées\nLiaison avec QG, drones, aviation\nGuerre électronique[/ul]",
	"Démineur / EOD": "[b]Démineur / Spécialiste explosifs[/b] (EOD / NEDEX)\n\n[ul]Neutralisation d'explosifs\nSabotage / ouverture de brèches\nPiégeage / contre-piégeage[/ul]",
	"Médecin de combat": "[b]Auxiliaire sanitaire / Médecin de combat[/b]\n\n[ul]Soins en conditions extrêmes\nMédecine de guerre (traumatologie, urgence)\nStabilisation avant évacuation[/ul]",
	"Renseignement": "[b]Renseignement[/b] (ISR / observation)\n\n[ul]Surveillance discrète longue durée\nCollecte d'informations terrain\nUtilisation de drones / capteurs[/ul]",
	"Spéc. insertion": "[b]Spécialiste insertion[/b] (chuteur opérationnel / nageur)\n\n[ul]Chuteur opérationnel (HALO/HAHO)\nNageur de combat / plongeur\nTechniques d'infiltration spécialisées[/ul]",
	"Spéc. appuis": "[b]Spécialiste appuis[/b] (air, drones, JTAC)\n\n[ul]Guidage des frappes aériennes (JTAC)\nPilotage de drones\nCoordination avec aviation[/ul]"
}

	
func _on_button_play_pressed():
	main.visible = false
	_load_character_list()
	_cs_panel.visible = true

func _ensure_missions_loaded() -> void:
	if not _missions.is_empty():
		return
	var path := "res://missions.json"
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data is Array:
		_missions = data

func _load_missions() -> void:
	_missions = []
	_selected_mission = {}
	ms_list.clear()
	ms_title.text    = ""
	ms_datetime.text = ""
	ms_description.text = ""
	ms_objectives.text  = ""
	ms_btn_accept.disabled = true
	var path := "res://missions.json"
	if not FileAccess.file_exists(path):
		push_warning("main_menu: missions.json introuvable")
		return
	var file := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Array:
		push_error("main_menu: missions.json invalide")
		return
	_missions = data
	for m in _missions:
		ms_list.add_item(m.get("title", "Mission sans titre"))

func _on_mission_list_item_selected(idx: int) -> void:
	if idx < 0 or idx >= _missions.size():
		return
	_selected_mission = _missions[idx]
	ms_title.text    = _selected_mission.get("title", "")
	ms_datetime.text = _format_mission_datetime(_selected_mission.get("start_datetime", ""))
	ms_description.text = _selected_mission.get("description", "")
	ms_objectives.text  = _selected_mission.get("objectives", "")
	ms_btn_accept.disabled = false

func _on_button_accept_pressed() -> void:
	if _selected_mission.is_empty():
		return
	if GameConfig.DEBUG:
		print("Mission acceptée : " + _selected_mission.get("title", ""))
	liblevel.load_game()
	var mission_id: String = _selected_mission.get("id", "")
	var state := liblevel.load_mission_state()
	if state.get("started", false) and state.get("mission_id", "") == mission_id:
		_show_mission_recap()
		return
	_launch_mission(_selected_mission, false)

func _launch_mission(mission: Dictionary, resume: bool) -> void:
	Player_data.current_mission_id = mission.get("id", "")
	var scene: String = mission.get("scene", "")
	var saved_matches: bool = (Player_data.scene_path == scene)
	if scene != "":
		Player_data.scene_path = scene
	if not resume:
		var spawn: Dictionary = mission.get("spawn", {})
		if not spawn.is_empty() and not saved_matches:
			Player_data.json_spawn     = Vector2(spawn.get("x", 0.0), spawn.get("y", 0.0))
			Player_data.use_json_spawn = true
		var dt_str: String = mission.get("start_datetime", "2024-01-01 08:00")
		Player_data.mission_start_unix      = _parse_datetime_to_unix(dt_str)
		Player_data.mission_real_start      = Time.get_unix_time_from_system()
		Player_data.mission_paused_duration = 0.0
		Player_data.mission_sunrise_hour = _parse_time_to_hour(mission.get("sunrise", "06:00"))
		Player_data.mission_sunset_hour  = _parse_time_to_hour(mission.get("sunset",  "20:00"))
		var dt := Time.get_datetime_dict_from_system()
		var started_at := "%04d-%02d-%02d %02d:%02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
		liblevel.save_mission_state(Player_data.current_mission_id, true, 0.0, started_at)
	SceneTransition.change_scene(Player_data.scene_path)

func _show_mission_recap() -> void:
	var state := liblevel.load_mission_state()
	var started_at: String = state.get("started_at", "")
	var saved_at: String   = state.get("saved_at", "")
	# Initialise les champs manquants (anciennes sauvegardes) et écrit le fichier
	if started_at == "" or saved_at == "":
		var dt := Time.get_datetime_dict_from_system()
		var now_str := "%04d-%02d-%02d %02d:%02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
		if started_at == "":
			started_at = now_str
		if saved_at == "":
			saved_at = now_str
		liblevel.save_mission_state(
			state.get("mission_id", Player_data.current_mission_id),
			true,
			state.get("mission_elapsed_real", 0.0),
			started_at
		)
	_mr_title.text         = _selected_mission.get("title", "")
	_mr_datetime.text      = _format_saved_at(saved_at)
	_mr_game_datetime.text = _format_game_datetime(state.get("game_datetime", ""))
	_mr_elapsed.text       = _format_elapsed(state.get("mission_elapsed_real", 0.0))
	_mr_health.text   = "Santé restante : %d / %d PV" % [Player_data.player_health, Player_data.player_health_base]
	_mr_objectives.text = _selected_mission.get("objectives", "")
	mission_select.visible = false
	_mr_panel.visible = true

func _on_recap_back_pressed() -> void:
	_mr_panel.visible = false
	_load_character_list()
	_cs_panel.visible = true

func _on_recap_continue_pressed() -> void:
	_mr_panel.visible = false
	var state := liblevel.load_mission_state()
	var elapsed: float = state.get("mission_elapsed_real", 0.0)
	Player_data.current_mission_id = _selected_mission.get("id", "")
	var scene: String = _selected_mission.get("scene", "")
	if scene != "":
		Player_data.scene_path = scene
	var dt_str: String = _selected_mission.get("start_datetime", "2024-01-01 08:00")
	Player_data.mission_start_unix      = _parse_datetime_to_unix(dt_str)
	Player_data.mission_real_start      = Time.get_unix_time_from_system() - elapsed
	Player_data.mission_paused_duration = 0.0
	Player_data.mission_sunrise_hour = _parse_time_to_hour(_selected_mission.get("sunrise", "06:00"))
	Player_data.mission_sunset_hour  = _parse_time_to_hour(_selected_mission.get("sunset",  "20:00"))
	SceneTransition.change_scene(Player_data.scene_path)

func _format_mission_datetime(dt_str: String) -> String:
	if dt_str == "":
		return ""
	var parts := dt_str.split(" ")
	if parts.size() < 2:
		return dt_str
	var d := parts[0].split("-")
	var t := parts[1].split(":")
	if d.size() < 3 or t.size() < 2:
		return dt_str
	return "Début : %s/%s/%s  %sh%s" % [d[2], d[1], d[0], t[0], t[1]]

func _format_started_at(dt_str: String) -> String:
	if dt_str == "":
		return "Date de départ inconnue"
	var parts := dt_str.split(" ")
	if parts.size() < 2:
		return dt_str
	var d := parts[0].split("-")
	var t := parts[1].split(":")
	if d.size() < 3 or t.size() < 2:
		return dt_str
	return "Commencé le %s/%s/%s à %sh%s" % [d[2], d[1], d[0], t[0], t[1]]

func _compute_game_datetime(elapsed: float) -> String:
	if Player_data.mission_start_unix <= 0.0:
		return ""
	var game_unix := Player_data.mission_start_unix + elapsed * 60.0
	var dt := Time.get_datetime_dict_from_unix_time(int(game_unix))
	return "%04d-%02d-%02d %02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute]

func _format_game_datetime(dt_str: String) -> String:
	if dt_str == "":
		return ""
	var parts := dt_str.split(" ")
	if parts.size() < 2:
		return dt_str
	var d := parts[0].split("-")
	var t := parts[1].split(":")
	if d.size() < 3 or t.size() < 2:
		return dt_str
	return "En jeu : %s/%s/%s  %sh%s" % [d[2], d[1], d[0], t[0], t[1]]

func _format_saved_at(dt_str: String) -> String:
	if dt_str == "":
		return "Dernière sauvegarde inconnue"
	var parts := dt_str.split(" ")
	if parts.size() < 2:
		return dt_str
	var d := parts[0].split("-")
	var t := parts[1].split(":")
	if d.size() < 3 or t.size() < 2:

		return dt_str
	return "Sauvegardé le %s/%s/%s à %sh%s" % [d[2], d[1], d[0], t[0], t[1]]

func _format_elapsed(seconds: float) -> String:
	var h: int = int(seconds / 3600.0)
	var m: int = int(fmod(seconds, 3600.0) / 60.0)
	if h > 0:
		return "Temps joué : %dh%02d" % [h, m]
	elif m > 0:
		return "Temps joué : %d min" % m
	else:
		return "Temps joué : moins d'une minute"

func _parse_time_to_hour(time_str: String) -> float:
	var parts := time_str.split(":")
	if parts.size() < 2:
		return 0.0
	return float(parts[0]) + float(parts[1]) / 60.0

func _parse_datetime_to_unix(dt_str: String) -> float:
	var parts := dt_str.split(" ")
	if parts.size() < 2:
		return 0.0
	var d := parts[0].split("-")
	var t := parts[1].split(":")
	if d.size() < 3 or t.size() < 2:
		return 0.0
	return Time.get_unix_time_from_datetime_dict({
		"year": int(d[0]), "month": int(d[1]), "day": int(d[2]),
		"hour": int(t[0]), "minute": int(t[1]), "second": 0
	})

func _on_button_mission_back_pressed() -> void:
	mission_select.visible = false
	_load_character_list()
	_cs_panel.visible = true

func _on_button_settings_pressed():
	main.visible = false
	help.visible = false
	settings.visible = true

func _on_button_help_pressed():
	main.visible = false
	settings.visible = false
	help.visible = true
	
func _on_button_quit_pressed():
	quit_dialog.popup_centered()

func _on_quit_dialog_confirmed():
	if GameConfig.DEBUG:
		print("Save Player")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		Player_data.player_pos_x = players[0].position.x
		Player_data.player_pos_y = players[0].position.y
	liblevel.savePlayer(data_to_save())
	PartyData.save_full_party()

	if GameConfig.DEBUG:
		print("Save all objects")
	var computers = get_tree().get_nodes_in_group("computer")
	var robots = get_tree().get_nodes_in_group("robot")
	var robot_enemies = get_tree().get_nodes_in_group("robot_enemy")
	var mechas = get_tree().get_nodes_in_group("mecha")
	var npcs = get_tree().get_nodes_in_group("npc")
	var current_scene = get_tree().get_current_scene().get_name()
	liblevel.saveAllObjects(current_scene, computers, robots, robot_enemies, mechas, npcs)

	if Player_data.current_mission_id != "":
		var elapsed: float
		if Player_data.mission_real_start > 0.0:
			elapsed = Time.get_unix_time_from_system() - Player_data.mission_real_start - Player_data.mission_paused_duration
		else:
			elapsed = liblevel.load_mission_state().get("mission_elapsed_real", 0.0)
		var game_datetime := _compute_game_datetime(elapsed)
		liblevel.save_mission_state(Player_data.current_mission_id, true, elapsed, "", game_datetime)

	if GameConfig.DEBUG:
		print("Credits")
	SceneTransition.change_scene("res://UI/credits.tscn")

func _on_button_audio_pressed():
	settings.visible = false
	audio_settings.visible = true
	check_music.button_pressed = !music_neon_dream.stream_paused
	slider_volume.value = db_to_linear(music_neon_dream.volume_db) * 100.0
	check_sfx.button_pressed = GameConfig.sfx_enabled
	slider_sfx_volume.value = GameConfig.sfx_volume_linear * 100.0
	check_intro_music.button_pressed = GameConfig.intro_music_enabled

func _on_button_audio_back_pressed():
	audio_settings.visible = false
	settings.visible = true

func _on_button_controls_pressed():
	settings.visible = false
	controls_settings.visible = true

func _on_button_controls_back_pressed():
	controls_settings.visible = false
	settings.visible = true

func _on_button_debug_pressed():
	settings.visible = false
	debug_settings.visible = true
	check_debug_hitbox.button_pressed = GameConfig.debug_show_hitbox
	check_debug_collision.button_pressed = GameConfig.debug_show_collision
	check_show_cone.button_pressed     = GameConfig.show_cone
	check_show_aim_line.button_pressed = GameConfig.show_aim_line

func _on_check_debug_hitbox_toggled(toggled_on: bool):
	GameConfig.debug_show_hitbox = toggled_on
	_save_audio_settings()

func _on_check_debug_collision_toggled(toggled_on: bool):
	GameConfig.debug_show_collision = toggled_on
	_save_audio_settings()

func _on_check_show_cone_toggled(toggled_on: bool):
	GameConfig.show_cone = toggled_on
	_save_audio_settings()

func _on_check_show_aim_line_toggled(toggled_on: bool):
	GameConfig.show_aim_line = toggled_on
	_save_audio_settings()

func _on_button_debug_back_pressed():
	debug_settings.visible = false
	settings.visible = true

func _on_button_video_pressed():
	settings.visible = false
	video_settings.visible = true
	check_fullscreen.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	_video_update_hint()

func _video_update_hint() -> void:
	var lbl: Label = $VideoSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelHint
	if not lbl:
		return
	if OS.has_feature("editor"):
		lbl.text = "Plein écran non disponible dans l'éditeur.\nLe réglage sera appliqué au lancement du jeu."
		lbl.visible = true
	else:
		lbl.visible = false

func _on_button_video_apply_pressed():
	if not OS.has_feature("editor"):
		if check_fullscreen.button_pressed:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save_audio_settings()

func _on_button_video_back_pressed():
	video_settings.visible = false
	settings.visible = true

func _on_button_create_character_pressed():
	_cc_from_cs = false
	main.visible = false
	character_creation.visible = true
	_cc_show_page(1)

func _cc_show_page(page: int):
	_cc_current_page           = page
	cc_page_identity.visible   = page == 1
	cc_page_appearance.visible = page == 2
	cc_page_military.visible   = page == 3
	cc_page_stats.visible      = page == 4
	cc_btn_back.visible        = page > 1
	cc_btn_next.visible        = page < 4
	cc_btn_create.visible      = page == 4
	if page == 1:
		cc_nickname.text  = ""
		cc_biography.text = ""
		cc_btn_next.disabled = true
		if not cc_nickname.text_changed.is_connected(_on_cc_nickname_changed):
			cc_nickname.text_changed.connect(_on_cc_nickname_changed)
	elif page == 2:
		_cc_init_appearance()
	elif page == 3:
		_cc_init_military()
	elif page == 4:
		cc_health.set_value_no_signal(10)
		cc_attack.set_value_no_signal(0)
		cc_defense.set_value_no_signal(0)
		cc_stamina.set_value_no_signal(0)
		cc_stealth.set_value_no_signal(0)
		cc_speed.set_value_no_signal(0)
		cc_precision.set_value_no_signal(0)
		cc_strength.set_value_no_signal(0)
		cc_intelligence.set_value_no_signal(0)
		cc_weight.set_value_no_signal(0)
		cc_movement.set_value_no_signal(0)
		_cc_update_remaining()

func _cc_init_appearance():
	_cc_populate_option(cc_body_opt,     "body")
	_cc_populate_option(cc_hair_opt,     "hair")
	_cc_populate_option(cc_headwear_opt, "headwear")
	_cc_populate_option(cc_arms_opt,     "arms")
	_cc_populate_option(cc_hands_opt,    "hands")
	_cc_populate_option(cc_torso_opt,    "torso")
	_cc_populate_option(cc_legs_opt,     "legs")
	_cc_populate_option(cc_feet_opt,     "feet")
	_cc_refresh_preview()

func _cc_populate_option(btn: OptionButton, slot: String) -> void:
	if btn.item_count > 0:
		return
	for opt in SpriteLibrary.get_slot_options(slot):
		btn.add_item(opt["label"])

func _cc_refresh_preview():
	_cc_set_sprite(cc_spr_body,     _cc_get_selected_key(cc_body_opt,     "body"))
	_cc_set_sprite(cc_spr_hair,     _cc_get_selected_key(cc_hair_opt,     "hair"))
	_cc_set_sprite(cc_spr_headwear, _cc_get_selected_key(cc_headwear_opt, "headwear"))
	_cc_set_sprite(cc_spr_torso,    _cc_get_selected_key(cc_torso_opt,    "torso"))
	_cc_set_sprite(cc_spr_legs,     _cc_get_selected_key(cc_legs_opt,     "legs"))
	_cc_set_sprite(cc_spr_feet,     _cc_get_selected_key(cc_feet_opt,     "feet"))
	_cc_set_sprite(cc_spr_gloves,   _cc_get_selected_key(cc_hands_opt,    "hands"))
	# Arms: armure (acier/fer) ou brassards
	var arms_key   = _cc_get_selected_key(cc_arms_opt, "arms")
	var arms_layer = SpriteLibrary.get_item_layer(arms_key)
	_cc_set_sprite(cc_spr_arms,    arms_key if arms_layer == "arms"    else "")
	_cc_set_sprite(cc_spr_bracers, arms_key if arms_layer == "bracers" else "")
	# Tête et visage de base (fixes)
	SpriteLibrary.apply_head_preview(cc_spr_head)
	SpriteLibrary.apply_face_preview(cc_spr_face)
	cc_spr_shoulders.texture = null

func _cc_get_selected_key(btn: OptionButton, slot: String) -> String:
	var options := SpriteLibrary.get_slot_options(slot)
	var idx := btn.selected
	if idx < 0 or idx >= options.size():
		return ""
	return options[idx]["key"]

func _cc_set_sprite(spr: Sprite2D, key: String) -> void:
	SpriteLibrary.apply_preview_sprite(spr, key)

func _on_cc_body_selected(_idx: int):     _cc_refresh_preview()
func _on_cc_hair_selected(_idx: int):     _cc_refresh_preview()
func _on_cc_headwear_selected(_idx: int): _cc_refresh_preview()
func _on_cc_arms_selected(_idx: int):     _cc_refresh_preview()
func _on_cc_hands_selected(_idx: int):    _cc_refresh_preview()
func _on_cc_torso_selected(_idx: int):    _cc_refresh_preview()
func _on_cc_legs_selected(_idx: int):     _cc_refresh_preview()
func _on_cc_feet_selected(_idx: int):     _cc_refresh_preview()

func _cc_init_military():
	if cc_rank.item_count == 0:
		for rank in CC_RANKS:
			cc_rank.add_item(rank)
	if cc_spec_list.item_count == 0:
		for spec in CC_SPECS.keys():
			cc_spec_list.add_item(spec)
	cc_spec_desc.text = "[i]Sélectionnez une spécialisation...[/i]"

func _on_cc_cancel_pressed():
	character_creation.visible = false
	if _cc_from_cs:
		_cc_from_cs = false
		_load_character_list()
		_cs_panel.visible = true
	else:
		main.visible = true

func _on_cc_nickname_changed(text: String) -> void:
	cc_btn_next.disabled = text.strip_edges().is_empty()

func _on_cc_back_pressed():
	_cc_show_page(_cc_current_page - 1)

func _on_cc_next_pressed():
	cc_btn_next.disabled = false
	_cc_show_page(_cc_current_page + 1)

func _on_cc_spec_selected(index: int):
	var spec_name = cc_spec_list.get_item_text(index)
	cc_spec_desc.text = CC_SPECS.get(spec_name, "")

func _cc_all_stats_sum() -> int:
	return int(cc_health.value) + int(cc_attack.value) + int(cc_defense.value) \
		+ int(cc_stamina.value) + int(cc_stealth.value) + int(cc_speed.value) \
		+ int(cc_precision.value) + int(cc_strength.value) \
		+ int(cc_intelligence.value) + int(cc_weight.value) + int(cc_movement.value)

func _cc_update_remaining():
	cc_remaining.text = "Points restants : " + str(TOTAL_POINTS - _cc_all_stats_sum())

func _cc_on_stat_changed(spinbox: SpinBox, value: float) -> void:
	var sum_others = _cc_all_stats_sum() - int(value)
	if int(value) + sum_others > TOTAL_POINTS:
		spinbox.set_value_no_signal(TOTAL_POINTS - sum_others)
	_cc_update_remaining()

func _on_cc_health_changed(value: float):    _cc_on_stat_changed(cc_health, value)
func _on_cc_attack_changed(value: float):    _cc_on_stat_changed(cc_attack, value)
func _on_cc_defense_changed(value: float):   _cc_on_stat_changed(cc_defense, value)
func _on_cc_stamina_changed(value: float):   _cc_on_stat_changed(cc_stamina, value)
func _on_cc_stealth_changed(value: float):   _cc_on_stat_changed(cc_stealth, value)
func _on_cc_speed_changed(value: float):     _cc_on_stat_changed(cc_speed, value)
func _on_cc_precision_changed(value: float): _cc_on_stat_changed(cc_precision, value)
func _on_cc_strength_changed(value: float):  _cc_on_stat_changed(cc_strength, value)
func _on_cc_intelligence_changed(value: float): _cc_on_stat_changed(cc_intelligence, value)
func _on_cc_weight_changed(value: float):    _cc_on_stat_changed(cc_weight, value)
func _on_cc_movement_changed(value: float):  _cc_on_stat_changed(cc_movement, value)

func _on_cc_create_pressed():
	Player_data.player_nickname      = cc_nickname.text.strip_edges()
	Player_data.player_biography     = cc_biography.text.strip_edges()
	Player_data.player_rank          = cc_rank.get_item_text(cc_rank.selected) if cc_rank.selected >= 0 else ""
	var sel = cc_spec_list.get_selected_items()
	Player_data.player_specialization = cc_spec_list.get_item_text(sel[0]) if sel.size() > 0 else ""
	Player_data.player_health        = int(cc_health.value)
	Player_data.player_health_base   = int(cc_health.value)
	Player_data.player_movement      = 50 + int(cc_movement.value) * 20
	Player_data.player_movement_base = 50 + int(cc_movement.value) * 20
	Player_data.player_attack        = int(cc_attack.value)
	Player_data.player_defense       = int(cc_defense.value)
	Player_data.player_stamina       = int(cc_stamina.value)
	Player_data.player_stealth       = int(cc_stealth.value)
	Player_data.player_speed         = int(cc_speed.value)
	Player_data.player_precision     = int(cc_precision.value)
	Player_data.player_strength      = int(cc_strength.value)
	Player_data.player_intelligence  = int(cc_intelligence.value)
	Player_data.player_weight_capacity = int(cc_weight.value)
	Player_data.player_credit          = 1000
	Player_data.player_equipment       = []
	Player_data.appearance_body      = _cc_get_selected_key(cc_body_opt,     "body")
	Player_data.appearance_hair      = _cc_get_selected_key(cc_hair_opt,     "hair")
	Player_data.appearance_headwear  = _cc_get_selected_key(cc_headwear_opt, "headwear")
	Player_data.appearance_arms      = _cc_get_selected_key(cc_arms_opt,     "arms")
	Player_data.appearance_hands     = _cc_get_selected_key(cc_hands_opt,    "hands")
	Player_data.appearance_torso     = _cc_get_selected_key(cc_torso_opt,    "torso")
	Player_data.appearance_legs      = _cc_get_selected_key(cc_legs_opt,     "legs")
	Player_data.appearance_feet      = _cc_get_selected_key(cc_feet_opt,     "feet")
	var slug := _slugify(Player_data.player_nickname)
	Player_data.set_character(slug)
	DirAccess.make_dir_recursive_absolute(Player_data.character_dir())
	liblevel.savePlayer({
		"player_position":        [Player_data_default.spawnpoint_position_x, Player_data_default.spawnpoint_position_y],
		"player_facing":          0,
		"scene":                  "",
		"player_health":          Player_data.player_health,
		"player_health_base":     Player_data.player_health_base,
		"player_movement":        Player_data.player_movement,
		"player_movement_base":   Player_data.player_movement_base,
		"player_attack":          Player_data.player_attack,
		"player_defense":         Player_data.player_defense,
		"player_stamina":         Player_data.player_stamina,
		"player_stealth":         Player_data.player_stealth,
		"player_speed":           Player_data.player_speed,
		"player_precision":       Player_data.player_precision,
		"player_strength":        Player_data.player_strength,
		"player_intelligence":    Player_data.player_intelligence,
		"player_weight_capacity": Player_data.player_weight_capacity,
		"player_credit":          Player_data.player_credit,
		"player_equipment":       Player_data.player_equipment,
		"player_nickname":        Player_data.player_nickname,
		"player_biography":       Player_data.player_biography,
		"player_rank":            Player_data.player_rank,
		"player_specialization":  Player_data.player_specialization,
		"appearance_body":        Player_data.appearance_body,
		"appearance_hair":        Player_data.appearance_hair,
		"appearance_headwear":    Player_data.appearance_headwear,
		"appearance_arms":        Player_data.appearance_arms,
		"appearance_hands":       Player_data.appearance_hands,
		"appearance_torso":       Player_data.appearance_torso,
		"appearance_legs":        Player_data.appearance_legs,
		"appearance_feet":        Player_data.appearance_feet
	})
	liblevel.reinitializeLevel()
	get_tree().paused = false
	character_creation.visible = false
	mission_select.visible = true
	_load_missions()

func _on_check_music_toggled(toggled_on: bool):
	music_neon_dream.stream_paused = !toggled_on
	_save_audio_settings()

func _on_slider_volume_value_changed(value: float):
	music_neon_dream.volume_db = linear_to_db(maxf(value, 0.01) / 100.0)
	_save_audio_settings()

func _on_check_sfx_toggled(toggled_on: bool):
	GameConfig.sfx_enabled = toggled_on
	_save_audio_settings()

func _on_check_intro_music_toggled(toggled_on: bool):
	GameConfig.intro_music_enabled = toggled_on
	_save_audio_settings()

func _on_slider_sfx_volume_value_changed(value: float):
	GameConfig.sfx_volume_linear = maxf(value, 0.01) / 100.0
	_save_audio_settings()

func _save_audio_settings():
	var data = {
		"music_paused": music_neon_dream.stream_paused,
		"volume_linear": db_to_linear(music_neon_dream.volume_db),
		"sfx_enabled": GameConfig.sfx_enabled,
		"sfx_volume_linear": GameConfig.sfx_volume_linear,
		"intro_music_enabled": GameConfig.intro_music_enabled,
		"debug_show_hitbox": GameConfig.debug_show_hitbox,
		"debug_show_collision": GameConfig.debug_show_collision,
		"show_cone": GameConfig.show_cone,
		"show_aim_line": GameConfig.show_aim_line,
		"fullscreen": DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	}
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	file.close()

func _load_audio_settings():
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		return
	music_neon_dream.stream_paused = data.get("music_paused", false)
	music_neon_dream.volume_db = linear_to_db(maxf(data.get("volume_linear", 0.8), 0.01))
	GameConfig.sfx_enabled = data.get("sfx_enabled", true)
	GameConfig.sfx_volume_linear = maxf(data.get("sfx_volume_linear", 0.8), 0.01)
	GameConfig.intro_music_enabled = data.get("intro_music_enabled", true)
	GameConfig.debug_show_hitbox = data.get("debug_show_hitbox", false)
	GameConfig.debug_show_collision = data.get("debug_show_collision", false)
	GameConfig.show_cone      = data.get("show_cone", true)
	GameConfig.show_aim_line  = data.get("show_aim_line", true)
	if data.get("fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func show_main_panel() -> void:
	settings.visible = false
	help.visible = false
	audio_settings.visible = false
	controls_settings.visible = false
	debug_settings.visible = false
	video_settings.visible = false
	mission_select.visible = false
	character_creation.visible = false
	if _mr_panel:
		_mr_panel.visible = false
	if _cs_panel:
		_cs_panel.visible = false
	if _cm_panel:
		_cm_panel.visible = false
	main.visible = true

func set_in_game_mode(enabled: bool) -> void:
	_in_game = enabled
	if _btn_settings_back:
		_btn_settings_back.text = "Retour au jeu" if enabled else "Retour"

func _on_button_settings_back_pressed():
	settings.visible = false
	help.visible = false
	audio_settings.visible = false
	controls_settings.visible = false
	video_settings.visible = false
	if _in_game:
		return_to_game.emit()
	else:
		main.visible = true

func _on_button_help_back_pressed() -> void:
	main.visible = true
	settings.visible = false
	help.visible = false
	
	
func _on_reinitialize_pressed():
	if GameConfig.DEBUG:
		print("Reinitialize")
	liblevel.reinitializePlayer()
	liblevel.reinitializeLevel()
	Player_data.player_previous_scene = ""
	Player_data.scene_path = ""
	Player_data.player_pos_x = 0
	Player_data.player_pos_y = 0
	Player_data.computer = 0
	Player_data.robot = 0
	Player_data.inventory = []
	Player_data.contact_object = null
	Player_data.contact_enemy = null
	Player_data.player_attack = randi_range(10, 15)
	Player_data.player_defense = randi_range(10, 15)
	get_tree().paused = false
	Player_data.set_character("")
	Player_data.goto_character_creation = true
	SceneTransition.change_scene("res://UI/main_menu.tscn")

func _slugify(nickname: String) -> String:
	var result := ""
	for ch in nickname.to_lower():
		var code := ch.unicode_at(0)
		if (code >= 97 and code <= 122) or (code >= 48 and code <= 57):
			result += ch
		elif ch == " " or ch == "-":
			result += "_"
	while result.begins_with("_"): result = result.substr(1)
	while result.ends_with("_"):   result = result.substr(0, result.length() - 1)
	if result == "": result = "player"
	return result


func _load_character_list() -> void:
	_cs_characters = []
	_cs_list.clear()
	_cs_selected_slug = ""
	_cs_btn_play.disabled = true
	var dir := DirAccess.open("user://characters/")
	if dir != null:
		dir.list_dir_begin()
		var slug := dir.get_next()
		while slug != "":
			if dir.current_is_dir() and not slug.begins_with("."):
				var rpg_path := "user://characters/%s/rpg.json" % slug
				if FileAccess.file_exists(rpg_path):
					var f := FileAccess.open(rpg_path, FileAccess.READ)
					var data = JSON.parse_string(f.get_as_text())
					f.close()
					if data is Dictionary:
						var has_mission := FileAccess.file_exists(
							"user://characters/%s/mission_state.json" % slug)
						_cs_characters.append({
							"slug": slug,
							"nickname": data.get("player_nickname", slug),
							"has_mission": has_mission
						})
			slug = dir.get_next()
	_cs_list.visible       = _cs_characters.size() > 0
	_cs_empty_label.visible = _cs_characters.size() == 0
	for ch in _cs_characters:
		var label: String = ch["nickname"]
		if ch["has_mission"]:
			label += "  ↩ mission en cours"
		_cs_list.add_item(label)


func _on_cs_list_selected(idx: int) -> void:
	if idx < 0 or idx >= _cs_characters.size():
		return
	_cs_selected_slug = _cs_characters[idx]["slug"]
	_cs_btn_play.disabled = false


func _on_cs_play_pressed() -> void:
	if _cs_selected_slug == "":
		return
	Player_data.set_character(_cs_selected_slug)
	liblevel.load_game()
	if PartyData.slot_count() == 0 or PartyData.slots[0].get("slug", "") != _cs_selected_slug:
		PartyData.setup_solo(_cs_selected_slug)
	else:
		PartyData.slots[0]["data"] = PartyData.snapshot_player_data()
		_load_slot_data_for_party()
	PartyData.save_party()
	var state := liblevel.load_mission_state()
	if state.get("started", false):
		var mission_id: String = state.get("mission_id", "")
		_load_missions()
		for i in range(_missions.size()):
			if _missions[i].get("id", "") == mission_id:
				_selected_mission = _missions[i]
				_cs_panel.visible = false
				_show_mission_recap()
				return
	_cs_panel.visible = false
	mission_select.visible = true
	_load_missions()


func _on_cs_new_pressed() -> void:
	Player_data.set_character("")
	_cc_from_cs = true
	_cs_panel.visible = false
	character_creation.visible = true
	_cc_show_page(1)


func _on_cs_back_pressed() -> void:
	_cs_panel.visible = false
	main.visible = true


func _build_character_select_panel() -> void:
	_cs_panel = Control.new()
	_cs_panel.name = "CharacterSelect"
	_cs_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cs_panel.visible = false
	add_child(_cs_panel)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cs_panel.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cs_panel.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "CHOISIR UN PERSONNAGE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	_cs_list = ItemList.new()
	_cs_list.custom_minimum_size = Vector2(0, 180)
	_cs_list.item_selected.connect(_on_cs_list_selected)
	vbox.add_child(_cs_list)

	_cs_empty_label = Label.new()
	_cs_empty_label.text = "Aucun personnage trouvé.\nCréez un nouveau personnage pour commencer."
	_cs_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cs_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cs_empty_label.visible = false
	vbox.add_child(_cs_empty_label)

	vbox.add_child(HSeparator.new())

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	vbox.add_child(buttons)

	var btn_back := Button.new()
	btn_back.text = "Retour"
	btn_back.pressed.connect(_on_cs_back_pressed)
	buttons.add_child(btn_back)

	var btn_new := Button.new()
	btn_new.text = "Nouveau personnage"
	btn_new.pressed.connect(_on_cs_new_pressed)
	buttons.add_child(btn_new)

	var btn_manage := Button.new()
	btn_manage.text = "Gérer"
	btn_manage.pressed.connect(_on_cm_manage_pressed)
	buttons.add_child(btn_manage)

	_cs_btn_play = Button.new()
	_cs_btn_play.text = "Jouer ▶"
	_cs_btn_play.disabled = true
	_cs_btn_play.pressed.connect(_on_cs_play_pressed)
	buttons.add_child(_cs_btn_play)


func _build_mission_recap_panel() -> void:
	_mr_panel = Control.new()
	_mr_panel.name = "MissionRecap"
	_mr_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mr_panel.visible = false
	add_child(_mr_panel)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mr_panel.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mr_panel.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var header := Label.new()
	header.text = "RÉCAPITULATIF DE MISSION"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)

	vbox.add_child(HSeparator.new())

	_mr_title = Label.new()
	_mr_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_mr_title)

	_mr_datetime = Label.new()
	_mr_datetime.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_mr_datetime)

	_mr_game_datetime = Label.new()
	_mr_game_datetime.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_mr_game_datetime)

	_mr_elapsed = Label.new()
	_mr_elapsed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_mr_elapsed)

	vbox.add_child(HSeparator.new())

	_mr_health = Label.new()
	_mr_health.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_mr_health)

	vbox.add_child(HSeparator.new())

	var obj_lbl := Label.new()
	obj_lbl.text = "Objectifs :"
	vbox.add_child(obj_lbl)

	_mr_objectives = RichTextLabel.new()
	_mr_objectives.bbcode_enabled = true
	_mr_objectives.fit_content = true
	_mr_objectives.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(_mr_objectives)

	vbox.add_child(HSeparator.new())

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 20)
	vbox.add_child(buttons)

	var btn_back := Button.new()
	btn_back.text = "Retour"
	btn_back.pressed.connect(_on_recap_back_pressed)
	buttons.add_child(btn_back)

	var btn_continue := Button.new()
	btn_continue.text = "Continuer"
	btn_continue.pressed.connect(_on_recap_continue_pressed)
	buttons.add_child(btn_continue)

func _build_character_manager_panel() -> void:
	_cm_panel = Control.new()
	_cm_panel.name = "CharacterManager"
	_cm_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cm_panel.visible = false
	add_child(_cm_panel)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cm_panel.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cm_panel.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "GESTION DES PERSONNAGES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 340)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	_cm_rows_vbox = VBoxContainer.new()
	_cm_rows_vbox.add_theme_constant_override("separation", 8)
	_cm_rows_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_cm_rows_vbox)

	vbox.add_child(HSeparator.new())

	var party_title := Label.new()
	party_title.text = "ÉQUIPE ACTIVE"
	party_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(party_title)

	_cm_party_vbox = VBoxContainer.new()
	_cm_party_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_cm_party_vbox)

	vbox.add_child(HSeparator.new())

	var btn_back := Button.new()
	btn_back.text = "Retour"
	btn_back.pressed.connect(_on_cm_back_pressed)
	vbox.add_child(btn_back)

	_cm_delete_dialog = ConfirmationDialog.new()
	_cm_delete_dialog.title = "Supprimer le personnage"
	_cm_delete_dialog.dialog_text = "Êtes-vous sûr de vouloir supprimer ce personnage ?\nCette action est irréversible."
	_cm_delete_dialog.confirmed.connect(_on_cm_delete_confirmed)
	add_child(_cm_delete_dialog)


func _load_character_manager() -> void:
	for child in _cm_rows_vbox.get_children():
		child.queue_free()
	_rebuild_party_panel()

	_ensure_missions_loaded()

	var dir := DirAccess.open("user://characters/")
	var slugs: Array = []
	if dir != null:
		dir.list_dir_begin()
		var slug := dir.get_next()
		while slug != "":
			if dir.current_is_dir() and not slug.begins_with("."):
				if FileAccess.file_exists("user://characters/%s/rpg.json" % slug):
					slugs.append(slug)
			slug = dir.get_next()
		dir.list_dir_end()

	if slugs.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "Aucun personnage trouvé."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_cm_rows_vbox.add_child(empty_lbl)
		return

	for sl in slugs:
		_cm_rows_vbox.add_child(_build_character_row(sl))


func _rebuild_party_panel() -> void:
	if _cm_party_vbox == null:
		return
	for c in _cm_party_vbox.get_children():
		c.queue_free()
	if PartyData.slot_count() == 0:
		var lbl := Label.new()
		lbl.text = "Aucune équipe configurée — cliquez 'Jouer' pour choisir un chef."
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		_cm_party_vbox.add_child(lbl)
		return
	for i in range(PartyData.slot_count()):
		var slug: String = PartyData.slots[i].get("slug", "")
		var nickname := slug
		var rpg_path := "user://characters/%s/rpg.json" % slug
		if FileAccess.file_exists(rpg_path):
			var f := FileAccess.open(rpg_path, FileAccess.READ)
			var d = JSON.parse_string(f.get_as_text())
			f.close()
			if d is Dictionary:
				nickname = d.get("player_nickname", slug)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var slot_lbl := Label.new()
		slot_lbl.text = "Slot %d  — %s%s" % [i + 1, nickname, "  (chef)" if i == 0 else ""]
		slot_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(slot_lbl)
		if i == PartyData.active_slot:
			var active_lbl := Label.new()
			active_lbl.text = "✓ actif"
			active_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
			row.add_child(active_lbl)
		_cm_party_vbox.add_child(row)

func _build_character_row(slug: String) -> Control:
	var nickname := slug
	var rpg_path := "user://characters/%s/rpg.json" % slug
	if FileAccess.file_exists(rpg_path):
		var f := FileAccess.open(rpg_path, FileAccess.READ)
		var data = JSON.parse_string(f.get_as_text())
		f.close()
		if data is Dictionary:
			nickname = data.get("player_nickname", slug)

	var mission_summary := "Aucune mission en cours"
	var ms_path := "user://characters/%s/mission_state.json" % slug
	if FileAccess.file_exists(ms_path):
		var f2 := FileAccess.open(ms_path, FileAccess.READ)
		var ms_data = JSON.parse_string(f2.get_as_text())
		f2.close()
		if ms_data is Dictionary and ms_data.get("started", false):
			var mission_id: String = ms_data.get("mission_id", "")
			var mission_title := mission_id
			for m in _missions:
				if m.get("id", "") == mission_id:
					mission_title = m.get("title", mission_id)
					break
			var elapsed: float = ms_data.get("mission_elapsed_real", 0.0)
			var saved_at: String = ms_data.get("saved_at", "")
			mission_summary = mission_title + "  —  " + _format_elapsed(elapsed)
			if saved_at != "":
				mission_summary += "  (" + _format_saved_at(saved_at) + ")"

	var row_panel := PanelContainer.new()
	var row_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		row_margin.add_theme_constant_override("margin_" + side, 8)
	row_panel.add_child(row_margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	row_margin.add_child(hbox)

	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_lbl := Label.new()
	name_lbl.text = nickname
	info_vbox.add_child(name_lbl)

	var mission_lbl := Label.new()
	mission_lbl.text = mission_summary
	mission_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	mission_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(mission_lbl)

	var btn_play := Button.new()
	btn_play.text = "Jouer ▶"
	btn_play.pressed.connect(_on_cm_play_pressed.bind(slug))
	hbox.add_child(btn_play)

	var can_join: bool = (PartyData.slot_count() > 0
		and not PartyData.has_slot(slug)
		and PartyData.slot_count() < PartyData.MAX_SLOTS)
	var is_leader: bool = (PartyData.slot_count() > 0
		and PartyData.slots[0].get("slug", "") == slug)

	if not is_leader and PartyData.has_slot(slug):
		var btn_leave := Button.new()
		btn_leave.text = "Quitter équipe"
		btn_leave.pressed.connect(_on_cm_leave_pressed.bind(slug))
		hbox.add_child(btn_leave)
	elif can_join:
		var btn_join := Button.new()
		btn_join.text = "Équipe +"
		btn_join.tooltip_text = "Ajouter à l'équipe du personnage chef"
		btn_join.pressed.connect(_on_cm_join_pressed.bind(slug))
		hbox.add_child(btn_join)

	var btn_delete := Button.new()
	btn_delete.text = "Supprimer"
	btn_delete.pressed.connect(_on_cm_delete_pressed.bind(slug))
	hbox.add_child(btn_delete)

	return row_panel


func _on_cm_manage_pressed() -> void:
	_cs_panel.visible = false
	_load_character_manager()
	_cm_panel.visible = true


func _on_cm_back_pressed() -> void:
	_cm_panel.visible = false
	_load_character_list()
	_cs_panel.visible = true


func _on_cm_play_pressed(slug: String) -> void:
	Player_data.set_character(slug)
	liblevel.load_game()
	# Si ce personnage est déjà chef → conserver l'équipe ; sinon démarrer en solo
	if PartyData.slot_count() == 0 or PartyData.slots[0].get("slug", "") != slug:
		PartyData.slots.clear()
		PartyData.active_slot = 0
		PartyData.slots.append({"slug": slug, "data": PartyData.snapshot_player_data()})
	else:
		PartyData.slots[0]["data"] = PartyData.snapshot_player_data()
		_load_slot_data_for_party()
	PartyData.save_party()
	var state := liblevel.load_mission_state()
	if state.get("started", false):
		var mission_id: String = state.get("mission_id", "")
		_ensure_missions_loaded()
		for i in range(_missions.size()):
			if _missions[i].get("id", "") == mission_id:
				_selected_mission = _missions[i]
				_cm_panel.visible = false
				_show_mission_recap()
				return
	_cm_panel.visible = false
	mission_select.visible = true
	_load_missions()

func _load_slot_data_for_party() -> void:
	for i in range(1, PartyData.slots.size()):
		var slot_slug: String = PartyData.slots[i].get("slug", "")
		if slot_slug == "":
			continue
		# Conserver les positions sauvegardées avant de recharger les stats
		var existing: Dictionary = PartyData.slots[i].get("data", {})
		var saved_pos_x = existing.get("pos_x", null)
		var saved_pos_y = existing.get("pos_y", null)
		print("[PARTY] _load_slot_data_for_party slot %d '%s' pos_x_avant=%s" % [i, slot_slug, saved_pos_x])
		var saved := Player_data.character_slug
		Player_data.set_character(slot_slug)
		liblevel.load_game()
		var fresh := PartyData.snapshot_player_data()
		if saved_pos_x != null:
			fresh["pos_x"] = saved_pos_x
		if saved_pos_y != null:
			fresh["pos_y"] = saved_pos_y
		PartyData.slots[i]["data"] = fresh
		print("[PARTY] _load_slot_data_for_party slot %d '%s' pos_x_après=%s" % [i, slot_slug, fresh.get("pos_x", "ABSENT")])
		Player_data.set_character(saved)
		liblevel.load_game()

func _on_cm_join_pressed(slug: String) -> void:
	if PartyData.slot_count() == 0:
		return  # pas de chef défini
	if PartyData.has_slot(slug) or PartyData.slot_count() >= PartyData.MAX_SLOTS:
		return
	var saved := Player_data.character_slug
	Player_data.set_character(slug)
	liblevel.load_game()
	var data := PartyData.snapshot_player_data()
	Player_data.set_character(saved)
	if saved != "":
		liblevel.load_game()
	PartyData.add_slot(slug, data)
	PartyData.save_party()
	_load_character_manager()

func _on_cm_leave_pressed(slug: String) -> void:
	PartyData.remove_slot_by_slug(slug)
	PartyData.save_party()
	_load_character_manager()


func _on_cm_delete_pressed(slug: String) -> void:
	_cm_delete_slug = slug
	_cm_delete_dialog.popup_centered()


func _on_cm_delete_confirmed() -> void:
	if _cm_delete_slug == "":
		return
	_delete_dir_recursive("user://characters/" + _cm_delete_slug)
	_cm_delete_slug = ""
	_load_character_manager()


func _delete_dir_recursive(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry != "." and entry != "..":
			var full := path + "/" + entry
			if dir.current_is_dir():
				_delete_dir_recursive(full)
			else:
				DirAccess.remove_absolute(full)
		entry = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(path)


func _connect_video_settings() -> void:
	var btn_video: Button = $Settings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Video
	var btn_apply: Button = $VideoSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonVideoApply
	var btn_back:  Button = $VideoSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonVideoBack
	if btn_video and not btn_video.pressed.is_connected(_on_button_video_pressed):
		btn_video.pressed.connect(_on_button_video_pressed)
	if btn_apply and not btn_apply.pressed.is_connected(_on_button_video_apply_pressed):
		btn_apply.pressed.connect(_on_button_video_apply_pressed)
	if btn_back and not btn_back.pressed.is_connected(_on_button_video_back_pressed):
		btn_back.pressed.connect(_on_button_video_back_pressed)

func _ready():
	if GameConfig.DEBUG:
		print("Init Game")
	if GameConfig.DEBUG:
		print(liblevel.displayVersion())

	# Restaurer l'équipe depuis party.json si elle n'est pas déjà en mémoire
	if PartyData.slot_count() == 0:
		PartyData.load_party()

	get_tree().set_auto_accept_quit(false)
	_build_mission_recap_panel()
	_build_character_select_panel()
	_build_character_manager_panel()
	_connect_video_settings()
	music_neon_dream.play()
	_load_audio_settings()
	SceneTransition.fade_in()

	if Player_data.goto_character_creation:
		Player_data.goto_character_creation = false
		_on_button_create_character_pressed()

func data_to_save():
	return {
		"player_position":       [Player_data.player_pos_x, Player_data.player_pos_y],
		"player_facing":         Player_data.player_facing,
		"scene":                 Player_data.player_previous_scene,
		"player_health":         Player_data.player_health,
		"player_health_base":    Player_data.player_health_base,
		"player_movement":        Player_data.player_movement,
		"player_movement_base":   Player_data.player_movement_base,
		"player_attack":          Player_data.player_attack,
		"player_defense":         Player_data.player_defense,
		"player_stamina":         Player_data.player_stamina,
		"player_stealth":         Player_data.player_stealth,
		"player_speed":           Player_data.player_speed,
		"player_precision":       Player_data.player_precision,
		"player_strength":        Player_data.player_strength,
		"player_intelligence":    Player_data.player_intelligence,
		"player_weight_capacity": Player_data.player_weight_capacity,
		"player_credit":          Player_data.player_credit,
		"player_equipment":       Player_data.player_equipment,
		"player_nickname":        Player_data.player_nickname,
		"player_biography":      Player_data.player_biography,
		"player_rank":           Player_data.player_rank,
		"player_specialization": Player_data.player_specialization,
		"appearance_body":       Player_data.appearance_body,
		"appearance_hair":       Player_data.appearance_hair,
		"appearance_headwear":   Player_data.appearance_headwear,
		"appearance_arms":       Player_data.appearance_arms,
		"appearance_hands":      Player_data.appearance_hands,
		"appearance_torso":      Player_data.appearance_torso,
		"appearance_legs":       Player_data.appearance_legs,
		"appearance_feet":       Player_data.appearance_feet
	}

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if GameConfig.DEBUG:
			print("You must quit via the quit button")
