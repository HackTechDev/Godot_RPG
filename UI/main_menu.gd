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
@onready var cc_page_identity: VBoxContainer = get_node(_CC_BASE + "/PageIdentity")
@onready var cc_page_military: VBoxContainer = get_node(_CC_BASE + "/PageMilitary")
@onready var cc_page_stats:    VBoxContainer = get_node(_CC_BASE + "/PageStats")

@onready var cc_nickname:  LineEdit      = get_node(_CC_BASE + "/PageIdentity/NicknameEdit")
@onready var cc_biography: TextEdit      = get_node(_CC_BASE + "/PageIdentity/BiographyEdit")
@onready var cc_rank:      OptionButton  = get_node(_CC_BASE + "/PageMilitary/RankOption")
@onready var cc_spec_list: ItemList      = get_node(_CC_BASE + "/PageMilitary/SpecRow/SpecList")
@onready var cc_spec_desc: RichTextLabel = get_node(_CC_BASE + "/PageMilitary/SpecRow/SpecDescPanel/SpecDescMargin/SpecDesc")
@onready var cc_health:    SpinBox       = get_node(_CC_BASE + "/PageStats/StatsContainer/HealthRow/HealthSpinBox")
@onready var cc_attack:    SpinBox       = get_node(_CC_BASE + "/PageStats/StatsContainer/AttackRow/AttackSpinBox")
@onready var cc_defense:   SpinBox       = get_node(_CC_BASE + "/PageStats/StatsContainer/DefenseRow/DefenseSpinBox")
@onready var cc_remaining: Label         = get_node(_CC_BASE + "/PageStats/LabelRemaining")

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
	cc_page_identity.visible = page == 1
	cc_page_military.visible = page == 2
	cc_page_stats.visible    = page == 3
	if page == 1:
		cc_nickname.text  = ""
		cc_biography.text = ""
	elif page == 2:
		_cc_init_military()
	elif page == 3:
		cc_health.value  = 10
		cc_attack.value  = 10
		cc_defense.value = 10
		_cc_update_remaining()

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

func _on_cc_back2_pressed():
	_cc_show_page(1)

func _on_cc_next2_pressed():
	_cc_show_page(3)

func _on_cc_back3_pressed():
	_cc_show_page(2)

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
		"player_specialization": Player_data.player_specialization
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
		"player_specialization": Player_data.player_specialization
	}

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if GameConfig.DEBUG:
			print("You must quit via the quit button")
