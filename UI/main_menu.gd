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
@onready var quit_dialog: ConfirmationDialog = $QuitDialog
@onready var music_neon_dream: AudioStreamPlayer = $"../Music_Neon_Dream"

const _CC_BASE = "CharacterCreation/CenterContainer/PanelContainer/MarginContainer/VBoxContainer"
const _CC_PA   = _CC_BASE + "/PageAppearance/ContentRow"

@onready var cc_page_identity:   VBoxContainer = get_node(_CC_BASE + "/PageIdentity")
@onready var cc_page_appearance: VBoxContainer = get_node(_CC_BASE + "/PageAppearance")
@onready var cc_page_military:   VBoxContainer = get_node(_CC_BASE + "/PageMilitary")
@onready var cc_page_stats:      VBoxContainer = get_node(_CC_BASE + "/PageStats")

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

# LPC Spritesheet frame: walk south/de face (row 10), first frame (col 0) = 10*13+0 = 130
const CC_PREVIEW_FRAME = 130
const CC_SPR_HFRAMES   = 13
const CC_SPR_VFRAMES   = 54

# Appearance options: key → {label, file}
# File paths relative to res://Sprites/Player/items/
# For optional slots, key "" means "Aucun" (none)
const CC_BODY_OPTIONS: Array = [
	{"key": "body_light", "label": "Carnation claire", "file": "010 body_color__light_.png"}
]
const CC_HAIR_OPTIONS: Array = [
	{"key": "",            "label": "Aucun",           "file": ""},
	{"key": "bangs_black", "label": "Frange (noir)",   "file": "120 bangs__black_.png"}
]
const CC_HEADWEAR_OPTIONS: Array = [
	{"key": "",                 "label": "Aucun",               "file": ""},
	{"key": "armet_iron",       "label": "Armet (fer)",         "file": "130 armet__iron_.png"},
	{"key": "xeon_steel",       "label": "Casque Xeon (acier)", "file": "130 xeon_helmet__steel_.png"}
]
const CC_ARMS_OPTIONS: Array = [
	{"key": "",              "label": "Aucun",             "file": ""},
	{"key": "armour_steel",  "label": "Armure (acier)",    "file": "060 armour__steel_.png"},
	{"key": "armour_iron",   "label": "Armure (fer)",      "file": "060 armour__iron_.png"},
	{"key": "bracers_steel", "label": "Brassards (acier)", "file": "070 bracers__steel_.png"}
]
const CC_HANDS_OPTIONS: Array = [
	{"key": "",              "label": "Aucun",          "file": ""},
	{"key": "gloves_black",  "label": "Gants (noir)",   "file": "070 gloves__black_.png"},
	{"key": "gloves_brown",  "label": "Gants (marron)", "file": "070 gloves__brown_.png"}
]
const CC_TORSO_OPTIONS: Array = [
	{"key": "",               "label": "Aucun",              "file": ""},
	{"key": "leather_forest", "label": "Cuir (forêt)",       "file": "060 leather__forest_.png"},
	{"key": "plate_silver",   "label": "Plaque (argent)",    "file": "060 plate__silver_.png"}
]
const CC_LEGS_OPTIONS: Array = [
	{"key": "",               "label": "Aucun",              "file": ""},
	{"key": "armour_ceramic", "label": "Armure (céramique)", "file": "020 armour__ceramic_.png"}
]
const CC_FEET_OPTIONS: Array = [
	{"key": "",                  "label": "Aucun",              "file": ""},
	{"key": "boots_black",       "label": "Bottes (noir)",      "file": "025 basic_boots__black_.png"},
	{"key": "boots_charcoal",    "label": "Bottes (charbon)",   "file": "025 basic_boots__charcoal_.png"}
]

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
	if GameConfig.DEBUG:
		print("loading...")
	liblevel.load_game()
	SceneTransition.change_scene(Player_data.scene_path)

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

func _on_button_audio_back_pressed():
	audio_settings.visible = false
	settings.visible = true

func _on_button_controls_pressed():
	settings.visible = false
	controls_settings.visible = true

func _on_button_controls_back_pressed():
	controls_settings.visible = false
	settings.visible = true

func _on_button_create_character_pressed():
	main.visible = false
	character_creation.visible = true
	_cc_show_page(1)

func _cc_show_page(page: int):
	cc_page_identity.visible   = page == 1
	cc_page_appearance.visible = page == 2
	cc_page_military.visible   = page == 3
	cc_page_stats.visible      = page == 4
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
	_cc_populate_option(cc_body_opt,     CC_BODY_OPTIONS)
	_cc_populate_option(cc_hair_opt,     CC_HAIR_OPTIONS)
	_cc_populate_option(cc_headwear_opt, CC_HEADWEAR_OPTIONS)
	_cc_populate_option(cc_arms_opt,     CC_ARMS_OPTIONS)
	_cc_populate_option(cc_hands_opt,    CC_HANDS_OPTIONS)
	_cc_populate_option(cc_torso_opt,    CC_TORSO_OPTIONS)
	_cc_populate_option(cc_legs_opt,     CC_LEGS_OPTIONS)
	_cc_populate_option(cc_feet_opt,     CC_FEET_OPTIONS)
	_cc_refresh_preview()

func _cc_populate_option(btn: OptionButton, options: Array):
	if btn.item_count > 0:
		return
	for opt in options:
		btn.add_item(opt["label"])

func _cc_refresh_preview():
	_cc_set_sprite(cc_spr_body,     _cc_get_selected_file(cc_body_opt,     CC_BODY_OPTIONS))
	_cc_set_sprite(cc_spr_hair,     _cc_get_selected_file(cc_hair_opt,     CC_HAIR_OPTIONS))
	_cc_set_sprite(cc_spr_headwear, _cc_get_selected_file(cc_headwear_opt, CC_HEADWEAR_OPTIONS))
	_cc_set_sprite(cc_spr_torso,    _cc_get_selected_file(cc_torso_opt,    CC_TORSO_OPTIONS))
	_cc_set_sprite(cc_spr_legs,     _cc_get_selected_file(cc_legs_opt,     CC_LEGS_OPTIONS))
	_cc_set_sprite(cc_spr_feet,     _cc_get_selected_file(cc_feet_opt,     CC_FEET_OPTIONS))
	_cc_set_sprite(cc_spr_gloves,   _cc_get_selected_file(cc_hands_opt,    CC_HANDS_OPTIONS))
	# Arms: armure (acier/fer) ou brassards
	var arms_file = _cc_get_selected_file(cc_arms_opt, CC_ARMS_OPTIONS)
	var is_armour  = arms_file in ["060 armour__steel_.png", "060 armour__iron_.png"]
	var is_bracers = arms_file == "070 bracers__steel_.png"
	_cc_set_sprite(cc_spr_arms,    arms_file if is_armour else "")
	_cc_set_sprite(cc_spr_bracers, arms_file if is_bracers else "")
	# Always show base head + face
	_cc_set_sprite(cc_spr_head, "100 human_male__light_.png")
	_cc_set_sprite(cc_spr_face, "101 neutral__light_.png")
	cc_spr_shoulders.texture = null

func _cc_get_selected_file(btn: OptionButton, options: Array) -> String:
	var idx = btn.selected
	if idx < 0 or idx >= options.size():
		return ""
	return options[idx]["file"]

func _cc_set_sprite(spr: Sprite2D, file: String):
	if file == "":
		spr.texture = null
		return
	var path = "res://Sprites/Player/items/" + file
	var tex = load(path)
	spr.texture   = tex
	spr.hframes   = CC_SPR_HFRAMES
	spr.vframes   = CC_SPR_VFRAMES
	spr.frame     = CC_PREVIEW_FRAME

func _on_cc_body_selected(_idx: int):     _cc_refresh_preview()
func _on_cc_hair_selected(_idx: int):     _cc_refresh_preview()
func _on_cc_headwear_selected(_idx: int): _cc_refresh_preview()
func _on_cc_arms_selected(_idx: int):     _cc_refresh_preview()
func _on_cc_hands_selected(_idx: int):    _cc_refresh_preview()
func _on_cc_torso_selected(_idx: int):    _cc_refresh_preview()
func _on_cc_legs_selected(_idx: int):     _cc_refresh_preview()
func _on_cc_feet_selected(_idx: int):     _cc_refresh_preview()

func _cc_get_appearance_key(btn: OptionButton, options: Array) -> String:
	var idx = btn.selected
	if idx < 0 or idx >= options.size():
		return ""
	return options[idx]["key"]

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

func _on_cc_next1_pressed():
	_cc_show_page(2)

func _on_cc_back_appearance_pressed():
	_cc_show_page(1)

func _on_cc_next_appearance_pressed():
	_cc_show_page(3)

func _on_cc_back2_pressed():
	_cc_show_page(2)

func _on_cc_next2_pressed():
	_cc_show_page(4)

func _on_cc_back3_pressed():
	_cc_show_page(3)

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
	Player_data.appearance_body      = _cc_get_appearance_key(cc_body_opt,     CC_BODY_OPTIONS)
	Player_data.appearance_hair      = _cc_get_appearance_key(cc_hair_opt,     CC_HAIR_OPTIONS)
	Player_data.appearance_headwear  = _cc_get_appearance_key(cc_headwear_opt, CC_HEADWEAR_OPTIONS)
	Player_data.appearance_arms      = _cc_get_appearance_key(cc_arms_opt,     CC_ARMS_OPTIONS)
	Player_data.appearance_hands     = _cc_get_appearance_key(cc_hands_opt,    CC_HANDS_OPTIONS)
	Player_data.appearance_torso     = _cc_get_appearance_key(cc_torso_opt,    CC_TORSO_OPTIONS)
	Player_data.appearance_legs      = _cc_get_appearance_key(cc_legs_opt,     CC_LEGS_OPTIONS)
	Player_data.appearance_feet      = _cc_get_appearance_key(cc_feet_opt,     CC_FEET_OPTIONS)
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

func _save_audio_settings():
	var data = {
		"music_paused": music_neon_dream.stream_paused,
		"volume_linear": db_to_linear(music_neon_dream.volume_db)
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
	Player_data.spawnpoint_current = ""
	Player_data.spawnpoint_next = ""
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
