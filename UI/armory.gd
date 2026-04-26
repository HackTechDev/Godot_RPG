extends CanvasLayer

const _KEY_LABELS := {
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

const _EFFECT_LABELS := {
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

const _MODE_LABELS := {
	"semi":        "Semi-auto",
	"auto":        "Automatique",
	"burst":       "Rafale",
	"bolt_action": "Verrou",
	"melee":       "Corps-à-corps",
}

const _CAT_KEYS := ["weapon", "armor", "gadget", "clothing"]

@onready var _item_list:  ItemList      = $Main/Center/Panel/Margin/VBox/ContentRow/LeftPanel/ItemList
@onready var _det_name:   Label         = $Main/Center/Panel/Margin/VBox/ContentRow/DetailScroll/DetailVBox/DetName
@onready var _det_model:  Label         = $Main/Center/Panel/Margin/VBox/ContentRow/DetailScroll/DetailVBox/DetModel
@onready var _det_desc:   RichTextLabel = $Main/Center/Panel/Margin/VBox/ContentRow/DetailScroll/DetailVBox/DetDesc
@onready var _det_stats:  VBoxContainer = $Main/Center/Panel/Margin/VBox/ContentRow/DetailScroll/DetailVBox/DetStats

var _current_cat:   int   = 0
var _current_items: Array = []

func _ready() -> void:
	_show_category(0)

func _show_category(idx: int) -> void:
	_current_cat = idx
	_current_items = _get_items(idx)
	_item_list.clear()
	for item in _current_items:
		_item_list.add_item(item.get("name", "?"))
	if _item_list.item_count > 0:
		_item_list.select(0)
		_show_item(_current_items[0])
	else:
		_clear_detail()

func _get_items(idx: int) -> Array:
	match idx:
		0: return ArmoryData.weapons
		1: return ArmoryData.armors
		2: return ArmoryData.gadgets
		3: return ArmoryData.clothes
	return []

func _show_item(item: Dictionary) -> void:
	_det_name.text  = item.get("name", "")
	var model: String = item.get("model", "")
	var ver:   String = item.get("version", "")
	_det_model.text = ("%s — %s" % [model, ver]) if ver != "" else model
	_det_desc.text  = item.get("description", "")

	for child in _det_stats.get_children():
		child.queue_free()

	_add_stat("Poids", "%.1f kg" % item.get("weight", 0.0))
	_add_stat("Prix",  "%d pts"  % int(item.get("price",  0)))

	var cat_key: String = _CAT_KEYS[_current_cat]
	var sub: Dictionary = item.get(cat_key, {})
	for key in sub:
		_add_stat(_label_key(key), _format_val(key, sub[key]))

func _add_stat(key: String, val: String) -> void:
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
	_det_stats.add_child(row)

func _label_key(key: String) -> String:
	return _KEY_LABELS.get(key, key)

func _format_val(key: String, val) -> String:
	if key == "effect":
		return _EFFECT_LABELS.get(str(val), str(val))
	if key == "damage_reduction":
		return "%d%%" % int(float(val) * 100)
	if key == "fire_modes" and val is Array:
		var modes: Array = val.map(func(m): return _MODE_LABELS.get(str(m), str(m)))
		return ", ".join(modes)
	if val is Array:
		return ", ".join(val.map(func(x): return str(x)))
	if val is bool:
		return "Oui" if val else "Non"
	if val is float:
		return ("%.1f" % val) if val != float(int(val)) else str(int(val))
	return str(val)

func _clear_detail() -> void:
	_det_name.text  = ""
	_det_model.text = ""
	_det_desc.text  = ""
	for child in _det_stats.get_children():
		child.queue_free()

func _on_item_list_item_selected(index: int) -> void:
	if index >= 0 and index < _current_items.size():
		_show_item(_current_items[index])

func _on_btn_weapons_pressed(): _show_category(0)
func _on_btn_armors_pressed():  _show_category(1)
func _on_btn_gadgets_pressed(): _show_category(2)
func _on_btn_clothes_pressed(): _show_category(3)

func _on_button_close_pressed():
	visible = false
