extends CanvasLayer

signal appearance_changed

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
@onready var _stats_col: VBoxContainer = get_node(_COL)
@onready var _stats_panel    = get_node(_BASE + "/StatsPanel")
@onready var _equip_panel              = get_node(_BASE + "/EquipPanel")
@onready var _equip_list_container: VBoxContainer = get_node(_BASE + "/EquipPanel/EquipListContainer")

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

# ─── Apparence ─────────────────────────────────────────────────────────────
const _APP_SLOTS: Array = [
	{"slot": "body",     "label": "Corps",           "prop": "appearance_body"},
	{"slot": "hair",     "label": "Cheveux",          "prop": "appearance_hair"},
	{"slot": "headwear", "label": "Couvre-chef",      "prop": "appearance_headwear"},
	{"slot": "arms",     "label": "Bras / Brassards", "prop": "appearance_arms"},
	{"slot": "hands",    "label": "Gants",            "prop": "appearance_hands"},
	{"slot": "torso",    "label": "Torse",            "prop": "appearance_torso"},
	{"slot": "legs",     "label": "Jambes",           "prop": "appearance_legs"},
	{"slot": "feet",     "label": "Pieds",            "prop": "appearance_feet"},
]

var _app_panel:     Control    = null
var _app_opts:      Dictionary = {}   # slot → OptionButton
var _app_saved_lbl: Label      = null

# ─── Popup détail équipement ───────────────────────────────────────────────
var _detail_popup:  Control        = null
var _dp_name:       Label          = null
var _dp_model:      Label          = null
var _dp_desc:       RichTextLabel  = null
var _dp_stats:      VBoxContainer  = null

const _KEY_LABELS: Dictionary = {
	"damage":               "Dégâts",
	"precision":            "Précision",
	"range":                "Portée (m)",
	"fire_rate":            "Cadence (cps/min)",
	"reload_time":          "Rechargement (s)",
	"magazine_size":        "Capacité chargeur",
	"noise":                "Bruit",
	"recoil":               "Recul",
	"mobility_penalty":     "Pénalité mobilité",
	"stealth_modifier":     "Mod. discrétion",
	"fire_modes":           "Modes de tir",
	"ammo_type":            "Munitions",
	"can_attach_silencer":  "Silencieux possible",
	"defense":              "Défense",
	"damage_reduction":     "Réduction dégâts",
	"stealth_penalty":      "Pénalité discrétion",
	"noise_increase":       "Augmentation bruit",
	"effect":               "Effet",
	"detection_radius":     "Rayon (m)",
	"duration":             "Durée (s)",
	"cooldown":             "Recharge (s)",
	"stealth_bonus":        "Bonus discrétion",
	"mobility_bonus":       "Bonus mobilité",
	"noise_reduction":      "Réduction bruit",
	"visibility_reduction": "Réduction visibilité",
	"temperature_resistance": "Résistance température",
}

const _EFFECT_LABELS: Dictionary = {
	"reveal_enemies":      "Révéler les ennemis",
	"night_vision":        "Vision nocturne",
	"thermal_detection":   "Détection thermique",
	"stun_enemies":        "Étourdir les ennemis",
	"smoke_screen":        "Écran de fumée",
	"heal_player":         "Soigner le joueur",
	"unlock_silent":       "Crochetage silencieux",
	"breach_door":         "Destruction de porte",
	"disable_electronics": "Désactiver l'électronique",
	"squad_coordination":  "Coordination d'escouade",
}

const _MODE_LABELS: Dictionary = {
	"semi":        "Semi-auto",
	"auto":        "Automatique",
	"burst":       "Rafale",
	"bolt_action": "Verrou",
	"melee":       "Corps-à-corps",
}


func _ready() -> void:
	_build_detail_popup()
	_build_appearance_panel()


# ─── Onglets ───────────────────────────────────────────────────────────────

func _on_tab_fiche_pressed():
	_content_row.visible  = true
	_stats_col.visible    = true
	_app_panel.visible    = false
	_stats_panel.visible  = false
	_equip_panel.visible  = false

func _on_tab_stats_pressed():
	_content_row.visible  = false
	_app_panel.visible    = false
	_stats_panel.visible  = true
	_equip_panel.visible  = false

func _on_tab_equipements_pressed():
	_content_row.visible  = false
	_app_panel.visible    = false
	_stats_panel.visible  = false
	_equip_panel.visible  = true

func _on_tab_apparence_pressed():
	_content_row.visible  = true
	_stats_col.visible    = false
	_app_panel.visible    = true
	_stats_panel.visible  = false
	_equip_panel.visible  = false
	_sync_appearance_opts()


# ─── Données ───────────────────────────────────────────────────────────────

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
		var lines: Array = []
		for item in Player_data.inventory:
			lines.append("- " + item["label"])
		label_inventory.text = "\n".join(lines)

	var cat_fr: Dictionary = {"weapon": "Arme", "armor": "Protection", "gadget": "Matériel", "clothing": "Vêtement"}
	for child in _equip_list_container.get_children():
		child.queue_free()
	if Player_data.player_equipment.is_empty():
		var lbl := Label.new()
		lbl.text = "(aucun)"
		lbl.add_theme_font_size_override("font_size", 14)
		_equip_list_container.add_child(lbl)
	else:
		for eq in Player_data.player_equipment:
			var cat: String = cat_fr.get(eq.get("category", ""), eq.get("category", ""))
			var btn := Button.new()
			btn.text = "• [%s]  %s" % [cat, eq.get("name", "?")]
			btn.add_theme_font_size_override("font_size", 14)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.flat = true
			var desc: String = eq.get("description", "")
			if desc != "":
				btn.tooltip_text = desc
			var eq_copy: Dictionary = (eq as Dictionary).duplicate()
			btn.pressed.connect(func(): _show_equipment_detail(eq_copy))
			_equip_list_container.add_child(btn)

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


# ─── Panneau Apparence ─────────────────────────────────────────────────────

func _build_appearance_panel() -> void:
	_app_panel = VBoxContainer.new()
	_app_panel.name = "AppearancePanel"
	_app_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_app_panel.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	_app_panel.add_theme_constant_override("separation", 8)
	_app_panel.visible = false
	_content_row.add_child(_app_panel)

	var title := Label.new()
	title.text = "Apparence du personnage"
	title.add_theme_font_size_override("font_size", 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_app_panel.add_child(title)

	_app_panel.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_app_panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(vbox)

	for slot_def in _APP_SLOTS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		vbox.add_child(row)

		var lbl := Label.new()
		lbl.text = slot_def.label + " :"
		lbl.custom_minimum_size = Vector2(130, 0)
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(lbl)

		var opt := OptionButton.new()
		opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		opt.add_theme_font_size_override("font_size", 13)
		for item in SpriteLibrary.get_slot_options(slot_def.slot):
			opt.add_item(item.label)
		var slot: String = slot_def.slot
		var prop: String = slot_def.prop
		opt.item_selected.connect(
			func(idx: int) -> void: _on_appearance_opt_selected(slot, prop, idx)
		)
		row.add_child(opt)
		_app_opts[slot] = opt

	_app_saved_lbl = Label.new()
	_app_saved_lbl.text = "✓ Apparence sauvegardée"
	_app_saved_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_app_saved_lbl.add_theme_color_override("font_color", Color(0.3, 0.85, 0.3, 1.0))
	_app_saved_lbl.add_theme_font_size_override("font_size", 13)
	_app_saved_lbl.visible = false
	_app_panel.add_child(_app_saved_lbl)


func _sync_appearance_opts() -> void:
	for slot_def in _APP_SLOTS:
		var slot: String = slot_def.slot
		var opt: OptionButton = _app_opts.get(slot)
		if not is_instance_valid(opt):
			continue
		var current_key: String = _get_appearance_prop(slot_def.prop)
		var opts: Array = SpriteLibrary.get_slot_options(slot)
		opt.set_block_signals(true)
		opt.selected = 0
		for i in opts.size():
			if opts[i].key == current_key:
				opt.selected = i
				break
		opt.set_block_signals(false)


func _on_appearance_opt_selected(slot: String, prop: String, idx: int) -> void:
	var opts: Array = SpriteLibrary.get_slot_options(slot)
	if idx < 0 or idx >= opts.size():
		return
	_set_appearance_prop(prop, opts[idx].key)
	_refresh_preview()
	appearance_changed.emit()
	_app_saved_lbl.visible = true
	get_tree().create_timer(1.5).timeout.connect(
		func() -> void:
			if is_instance_valid(_app_saved_lbl):
				_app_saved_lbl.visible = false
	)


func _get_appearance_prop(prop: String) -> String:
	match prop:
		"appearance_body":     return Player_data.appearance_body
		"appearance_hair":     return Player_data.appearance_hair
		"appearance_headwear": return Player_data.appearance_headwear
		"appearance_arms":     return Player_data.appearance_arms
		"appearance_hands":    return Player_data.appearance_hands
		"appearance_torso":    return Player_data.appearance_torso
		"appearance_legs":     return Player_data.appearance_legs
		"appearance_feet":     return Player_data.appearance_feet
	return ""


func _set_appearance_prop(prop: String, value: String) -> void:
	match prop:
		"appearance_body":     Player_data.appearance_body = value
		"appearance_hair":     Player_data.appearance_hair = value
		"appearance_headwear": Player_data.appearance_headwear = value
		"appearance_arms":     Player_data.appearance_arms = value
		"appearance_hands":    Player_data.appearance_hands = value
		"appearance_torso":    Player_data.appearance_torso = value
		"appearance_legs":     Player_data.appearance_legs = value
		"appearance_feet":     Player_data.appearance_feet = value


# ─── Prévisualisation ──────────────────────────────────────────────────────

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


# ─── Popup détail équipement ───────────────────────────────────────────────

func _build_detail_popup() -> void:
	_detail_popup = Control.new()
	_detail_popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail_popup.visible = false
	get_node("Main").add_child(_detail_popup)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail_popup.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail_popup.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	_dp_name = Label.new()
	_dp_name.add_theme_font_size_override("font_size", 20)
	vbox.add_child(_dp_name)

	_dp_model = Label.new()
	_dp_model.add_theme_font_size_override("font_size", 13)
	vbox.add_child(_dp_model)

	_dp_desc = RichTextLabel.new()
	_dp_desc.bbcode_enabled = false
	_dp_desc.fit_content = true
	_dp_desc.scroll_active = false
	_dp_desc.add_theme_font_size_override("normal_font_size", 13)
	vbox.add_child(_dp_desc)

	vbox.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 80)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	_dp_stats = VBoxContainer.new()
	_dp_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dp_stats.add_theme_constant_override("separation", 6)
	scroll.add_child(_dp_stats)

	var btn_close := Button.new()
	btn_close.text = "Fermer"
	btn_close.pressed.connect(_hide_equipment_detail)
	vbox.add_child(btn_close)


func _show_equipment_detail(eq: Dictionary) -> void:
	var item := _find_item_in_armory(eq.get("id", ""))
	if item.is_empty():
		item = eq

	_dp_name.text = item.get("name", eq.get("name", ""))
	var model: String = item.get("model", "")
	var ver:   String = item.get("version", "")
	_dp_model.text = ("%s — %s" % [model, ver]) if ver != "" else model
	_dp_desc.text  = item.get("description", eq.get("description", ""))

	for child in _dp_stats.get_children():
		child.queue_free()

	_dp_add_stat("Poids", "%.1f kg" % item.get("weight", 0.0))
	_dp_add_stat("Prix",  "%d ¤"    % int(item.get("price", 0)))

	var cat_key: String = item.get("category", "")
	var sub: Dictionary = item.get(cat_key, {})
	for key in sub:
		_dp_add_stat(_dp_label_key(key), _dp_format_val(key, sub[key]))

	_detail_popup.visible = true


func _hide_equipment_detail() -> void:
	_detail_popup.visible = false


func _find_item_in_armory(item_id: String) -> Dictionary:
	for item in ArmoryData.weapons:
		if item.get("id", "") == item_id: return item
	for item in ArmoryData.armors:
		if item.get("id", "") == item_id: return item
	for item in ArmoryData.gadgets:
		if item.get("id", "") == item_id: return item
	for item in ArmoryData.clothes:
		if item.get("id", "") == item_id: return item
	return {}


func _dp_add_stat(key: String, val: String) -> void:
	var row := HBoxContainer.new()
	var lk  := Label.new()
	lk.text = key + " :"
	lk.custom_minimum_size = Vector2(190, 0)
	lk.add_theme_font_size_override("font_size", 13)
	var lv := Label.new()
	lv.text = val
	lv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lv.add_theme_font_size_override("font_size", 13)
	row.add_child(lk)
	row.add_child(lv)
	_dp_stats.add_child(row)


func _dp_label_key(key: String) -> String:
	return _KEY_LABELS.get(key, key)


func _dp_format_val(key: String, val: Variant) -> String:
	if key == "effect":
		return _EFFECT_LABELS.get(str(val), str(val))
	if key == "damage_reduction":
		return "%d%%" % int(float(val) * 100)
	if key == "fire_modes" and val is Array:
		var modes: Array = val.map(func(m: Variant) -> String: return _MODE_LABELS.get(str(m), str(m)))
		return ", ".join(modes)
	if val is Array:
		return ", ".join(val.map(func(x: Variant) -> String: return str(x)))
	if val is bool:
		return "Oui" if val else "Non"
	if val is float:
		return ("%.1f" % val) if val != float(int(val)) else str(int(val))
	return str(val)


# ─── Fermeture ─────────────────────────────────────────────────────────────

func _on_button_close_pressed():
	_hide_equipment_detail()
	visible = false
