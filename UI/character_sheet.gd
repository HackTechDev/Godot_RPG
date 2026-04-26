extends CanvasLayer

const _BASE  = "Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer"
const _COL   = _BASE + "/ContentRow/StatsColumn"
const _VP    = _BASE + "/ContentRow/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport"
const _SP    = _BASE + "/StatsPanel/StatsGrid"

@onready var label_health    = get_node(_COL + "/LabelHealth")
@onready var label_attack    = get_node(_COL + "/LabelAttack")
@onready var label_defense   = get_node(_COL + "/LabelDefense")
@onready var label_computers = get_node(_COL + "/LabelComputers")
@onready var label_robots    = get_node(_COL + "/LabelRobots")
@onready var label_scene     = get_node(_COL + "/LabelScene")
@onready var label_credit    = get_node(_COL + "/LabelCredit")
@onready var label_inventory = get_node(_COL + "/LabelInventory")

@onready var preview_panel   = get_node(_BASE + "/ContentRow/PreviewPanel")
@onready var _content_row    = get_node(_BASE + "/ContentRow")
@onready var _stats_panel    = get_node(_BASE + "/StatsPanel")

@onready var _ls_health       = get_node(_SP + "/ColLeft/LabelStatHealth")
@onready var _ls_attack       = get_node(_SP + "/ColLeft/LabelStatAttack")
@onready var _ls_defense      = get_node(_SP + "/ColLeft/LabelStatDefense")
@onready var _ls_stamina      = get_node(_SP + "/ColLeft/LabelStatStamina")
@onready var _ls_stealth      = get_node(_SP + "/ColLeft/LabelStatStealth")
@onready var _ls_speed        = get_node(_SP + "/ColRight/LabelStatSpeed")
@onready var _ls_precision    = get_node(_SP + "/ColRight/LabelStatPrecision")
@onready var _ls_strength     = get_node(_SP + "/ColRight/LabelStatStrength")
@onready var _ls_intelligence = get_node(_SP + "/ColRight/LabelStatIntelligence")
@onready var _ls_weight       = get_node(_SP + "/ColRight/LabelStatWeight")
@onready var _spr_body       = get_node(_VP + "/SpriteBody")
@onready var _spr_legs       = get_node(_VP + "/SpriteLegs")
@onready var _spr_feet       = get_node(_VP + "/SpriteFeet")
@onready var _spr_shoulders  = get_node(_VP + "/SpriteShoulders")
@onready var _spr_torso      = get_node(_VP + "/SpriteTorso")
@onready var _spr_arms       = get_node(_VP + "/SpriteArms")
@onready var _spr_bracers    = get_node(_VP + "/SpriteBracers")
@onready var _spr_gloves     = get_node(_VP + "/SpriteGloves")
@onready var _spr_head       = get_node(_VP + "/SpriteHead")
@onready var _spr_face       = get_node(_VP + "/SpriteFace")
@onready var _spr_hair       = get_node(_VP + "/SpriteHair")
@onready var _spr_headwear   = get_node(_VP + "/SpriteHeadwear")


func refresh():
	label_health.text    = "Santé : "       + str(Player_data.player_health)
	label_attack.text    = "Attaque : "     + str(Player_data.player_attack)
	label_defense.text   = "Défense : "     + str(Player_data.player_defense)
	label_computers.text = "Ordinateurs : " + str(Player_data.computer)
	label_robots.text    = "Robots : "      + str(Player_data.robot)
	label_scene.text     = "Zone : "        + Player_data.player_previous_scene
	label_credit.text    = "Crédit : "      + str(Player_data.player_credit) + " ¤"

	if Player_data.inventory.is_empty():
		label_inventory.text = "(vide)"
	else:
		var lines = []
		for item in Player_data.inventory:
			lines.append("- " + item["label"])
		label_inventory.text = "\n".join(lines)

	_ls_health.text       = "Santé : %d / 20"              % Player_data.player_health
	_ls_attack.text       = "Attaque : %d / 20"            % Player_data.player_attack
	_ls_defense.text      = "Défense : %d / 20"            % Player_data.player_defense
	_ls_stamina.text      = "Endurance : %d / 20"          % Player_data.player_stamina
	_ls_stealth.text      = "Discrétion : %d / 20"         % Player_data.player_stealth
	_ls_speed.text        = "Vitesse : %d / 20"            % Player_data.player_speed
	_ls_precision.text    = "Précision : %d / 20"          % Player_data.player_precision
	_ls_strength.text     = "Force : %d / 20"              % Player_data.player_strength
	_ls_intelligence.text = "Intelligence : %d / 20"       % Player_data.player_intelligence
	_ls_weight.text       = "Capacité de charge : %d / 20" % Player_data.player_weight_capacity

	_refresh_preview()

func _on_tab_fiche_pressed():
	_content_row.visible = true
	_stats_panel.visible = false

func _on_tab_stats_pressed():
	_content_row.visible = false
	_stats_panel.visible = true

func _refresh_preview():
	if Player_data.appearance_body == "":
		preview_panel.visible = false
		return
	preview_panel.visible = true
	_load(_spr_body,    Player_data.appearance_body)
	_load(_spr_legs,    Player_data.appearance_legs)
	_load(_spr_feet,    Player_data.appearance_feet)
	_none(_spr_shoulders)
	_load(_spr_torso,   Player_data.appearance_torso)
	var arms = Player_data.appearance_arms
	match SpriteLibrary.get_item_layer(arms):
		"arms":    _load(_spr_arms, arms); _none(_spr_bracers)
		"bracers": _none(_spr_arms);       _load(_spr_bracers, arms)
		_:         _none(_spr_arms);       _none(_spr_bracers)
	_load(_spr_gloves,  Player_data.appearance_hands)
	SpriteLibrary.apply_head_preview(_spr_head)
	SpriteLibrary.apply_face_preview(_spr_face)
	_load(_spr_hair,    Player_data.appearance_hair)
	_load(_spr_headwear, Player_data.appearance_headwear)

func _load(spr: Sprite2D, key: String) -> void:
	SpriteLibrary.apply_preview_sprite_centered(spr, key)

func _none(spr: Sprite2D) -> void:
	spr.visible = false

func _on_button_close_pressed():
	visible = false
