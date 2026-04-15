extends CanvasLayer

const SETTINGS_PATH = "user://settings.json"
const TOTAL_POINTS = 30

var liblevel = preload("res://Lib/liblevel.gd").new()

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
@onready var mission_select: Control = $MissionSelect
@onready var debug_settings: Control = $DebugSettings
@onready var check_debug_hitbox: CheckButton = $DebugSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckDebugHitbox
@onready var check_debug_collision: CheckButton = $DebugSettings/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CheckDebugCollision
@onready var quit_dialog: ConfirmationDialog = $QuitDialog

const _MS_BASE = "MissionSelect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer"
@onready var ms_list:        ItemList      = get_node(_MS_BASE + "/MissionList")
@onready var ms_title:       Label         = get_node(_MS_BASE + "/LabelMissionTitle")
@onready var ms_description: RichTextLabel = get_node(_MS_BASE + "/TextDescription")
@onready var ms_objectives:  RichTextLabel = get_node(_MS_BASE + "/TextObjectives")
@onready var ms_btn_accept:  Button        = get_node(_MS_BASE + "/ButtonsRow/ButtonAccept")

var _missions: Array = []
var _selected_mission: Dictionary = {}
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
@onready var cc_health:    SpinBox       = get_node(_CC_BASE + "/PageStats/StatsContainer/HealthRow/HealthSpinBox")
@onready var cc_attack:    SpinBox       = get_node(_CC_BASE + "/PageStats/StatsContainer/AttackRow/AttackSpinBox")
@onready var cc_defense:   SpinBox       = get_node(_CC_BASE + "/PageStats/StatsContainer/DefenseRow/DefenseSpinBox")
@onready var cc_remaining: Label         = get_node(_CC_BASE + "/PageStats/LabelRemaining")

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
	mission_select.visible = true
	_load_missions()

func _load_missions() -> void:
	_missions = []
	_selected_mission = {}
	ms_list.clear()
	ms_title.text = ""
	ms_description.text = ""
	ms_objectives.text = ""
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
	ms_title.text = _selected_mission.get("title", "")
	ms_description.text = _selected_mission.get("description", "")
	ms_objectives.text = _selected_mission.get("objectives", "")
	ms_btn_accept.disabled = false

func _on_button_accept_pressed() -> void:
	if _selected_mission.is_empty():
		return
	if GameConfig.DEBUG:
		print("Mission acceptée : " + _selected_mission.get("title", ""))
	liblevel.load_game()
	var scene: String = _selected_mission.get("scene", "")
	if scene != "":
		Player_data.scene_path = scene
	var spawn: Dictionary = _selected_mission.get("spawn", {})
	if not spawn.is_empty():
		Player_data.json_spawn     = Vector2(spawn.get("x", 0.0), spawn.get("y", 0.0))
		Player_data.use_json_spawn = true
	var dt_str: String = _selected_mission.get("start_datetime", "2024-01-01 08:00")
	Player_data.mission_start_unix = _parse_datetime_to_unix(dt_str)
	Player_data.mission_real_start = Time.get_unix_time_from_system()
	SceneTransition.change_scene(Player_data.scene_path)

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
	main.visible = true

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
	liblevel.savePlayer(data_to_save())

	if GameConfig.DEBUG:
		print("Save all objects")
	var computers = get_tree().get_nodes_in_group("computer")
	var robots = get_tree().get_nodes_in_group("robot")
	var robot_enemies = get_tree().get_nodes_in_group("robot_enemy")
	var current_scene = get_tree().get_current_scene().get_name()
	liblevel.saveAllObjects(current_scene, computers, robots, robot_enemies)

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

func _on_check_debug_hitbox_toggled(toggled_on: bool):
	GameConfig.debug_show_hitbox = toggled_on
	_save_audio_settings()

func _on_check_debug_collision_toggled(toggled_on: bool):
	GameConfig.debug_show_collision = toggled_on
	_save_audio_settings()

func _on_button_debug_back_pressed():
	debug_settings.visible = false
	settings.visible = true

func _on_button_create_character_pressed():
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
	elif page == 2:
		_cc_init_appearance()
	elif page == 3:
		_cc_init_military()
	elif page == 4:
		cc_health.value  = 10
		cc_attack.value  = 10
		cc_defense.value = 10
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
	main.visible = true

func _on_cc_back_pressed():
	_cc_show_page(_cc_current_page - 1)

func _on_cc_next_pressed():
	_cc_show_page(_cc_current_page + 1)

func _on_cc_spec_selected(index: int):
	var spec_name = cc_spec_list.get_item_text(index)
	cc_spec_desc.text = CC_SPECS.get(spec_name, "")

func _cc_update_remaining():
	var remaining = TOTAL_POINTS - int(cc_health.value) - int(cc_attack.value) - int(cc_defense.value)
	cc_remaining.text = "Points restants : " + str(remaining)

func _on_cc_health_changed(value: float):
	var others = int(cc_attack.value) + int(cc_defense.value)
	if int(value) + others > TOTAL_POINTS:
		cc_health.set_value_no_signal(TOTAL_POINTS - others)
	_cc_update_remaining()

func _on_cc_attack_changed(value: float):
	var others = int(cc_health.value) + int(cc_defense.value)
	if int(value) + others > TOTAL_POINTS:
		cc_attack.set_value_no_signal(TOTAL_POINTS - others)
	_cc_update_remaining()

func _on_cc_defense_changed(value: float):
	var others = int(cc_health.value) + int(cc_attack.value)
	if int(value) + others > TOTAL_POINTS:
		cc_defense.set_value_no_signal(TOTAL_POINTS - others)
	_cc_update_remaining()

func _on_cc_create_pressed():
	Player_data.player_nickname      = cc_nickname.text.strip_edges()
	Player_data.player_biography     = cc_biography.text.strip_edges()
	Player_data.player_rank          = cc_rank.get_item_text(cc_rank.selected) if cc_rank.selected >= 0 else ""
	var sel = cc_spec_list.get_selected_items()
	Player_data.player_specialization = cc_spec_list.get_item_text(sel[0]) if sel.size() > 0 else ""
	Player_data.player_health        = int(cc_health.value)
	Player_data.player_health_base   = int(cc_health.value)
	Player_data.player_attack        = int(cc_attack.value)
	Player_data.player_defense       = int(cc_defense.value)
	Player_data.appearance_body      = _cc_get_selected_key(cc_body_opt,     "body")
	Player_data.appearance_hair      = _cc_get_selected_key(cc_hair_opt,     "hair")
	Player_data.appearance_headwear  = _cc_get_selected_key(cc_headwear_opt, "headwear")
	Player_data.appearance_arms      = _cc_get_selected_key(cc_arms_opt,     "arms")
	Player_data.appearance_hands     = _cc_get_selected_key(cc_hands_opt,    "hands")
	Player_data.appearance_torso     = _cc_get_selected_key(cc_torso_opt,    "torso")
	Player_data.appearance_legs      = _cc_get_selected_key(cc_legs_opt,     "legs")
	Player_data.appearance_feet      = _cc_get_selected_key(cc_feet_opt,     "feet")
	liblevel.savePlayer({
		"player_position":      [Player_data_default.spawnpoint_position_x, Player_data_default.spawnpoint_position_y],
		"player_facing":        0,
		"scene":                "",
		"player_health":        Player_data.player_health,
		"player_health_base":   Player_data.player_health_base,
		"player_attack":        Player_data.player_attack,
		"player_defense":       Player_data.player_defense,
		"player_nickname":      Player_data.player_nickname,
		"player_biography":     Player_data.player_biography,
		"player_rank":          Player_data.player_rank,
		"player_specialization": Player_data.player_specialization,
		"appearance_body":      Player_data.appearance_body,
		"appearance_hair":      Player_data.appearance_hair,
		"appearance_headwear":  Player_data.appearance_headwear,
		"appearance_arms":      Player_data.appearance_arms,
		"appearance_hands":     Player_data.appearance_hands,
		"appearance_torso":     Player_data.appearance_torso,
		"appearance_legs":      Player_data.appearance_legs,
		"appearance_feet":      Player_data.appearance_feet
	})
	liblevel.reinitializeLevel()
	liblevel.load_game()
	get_tree().paused = false
	SceneTransition.change_scene(Player_data.scene_path)

func _on_check_music_toggled(toggled_on: bool):
	music_neon_dream.stream_paused = !toggled_on
	_save_audio_settings()

func _on_slider_volume_value_changed(value: float):
	music_neon_dream.volume_db = linear_to_db(maxf(value, 0.01) / 100.0)
	_save_audio_settings()

func _on_check_sfx_toggled(toggled_on: bool):
	GameConfig.sfx_enabled = toggled_on
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
		"debug_show_hitbox": GameConfig.debug_show_hitbox,
		"debug_show_collision": GameConfig.debug_show_collision
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
	GameConfig.debug_show_hitbox = data.get("debug_show_hitbox", false)
	GameConfig.debug_show_collision = data.get("debug_show_collision", false)

func _on_button_settings_back_pressed():
	main.visible = true
	settings.visible = false
	help.visible = false
	audio_settings.visible = false
	controls_settings.visible = false

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
	Player_data.goto_character_creation = true
	SceneTransition.change_scene("res://UI/main_menu.tscn")

func _ready():
	if GameConfig.DEBUG:
		print("Init Game")
	if GameConfig.DEBUG:
		print(liblevel.displayVersion())
	
	get_tree().set_auto_accept_quit(false)

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
		"player_attack":         Player_data.player_attack,
		"player_defense":        Player_data.player_defense,
		"player_nickname":       Player_data.player_nickname,
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
